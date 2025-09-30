document.addEventListener("DOMContentLoaded", function () {
    const radialMenuContainer = document.getElementById('radial-menu-container');
    let nuiDotsContainer = document.getElementById('nui-dots-container');
    let contextDotsContainer = document.getElementById('context-dots-container');
    let playerTagsContainer = document.getElementById('player-tags-container');

    // Create dot containers if they don't exist in the HTML
    if (!nuiDotsContainer) {
        nuiDotsContainer = document.createElement('div');
        nuiDotsContainer.id = 'nui-dots-container';
        document.body.appendChild(nuiDotsContainer);
    }
    if (!contextDotsContainer) {
        contextDotsContainer = document.createElement('div');
        contextDotsContainer.id = 'context-dots-container';
        document.body.appendChild(contextDotsContainer);
    }
    if (!playerTagsContainer) {
        playerTagsContainer = document.createElement('div');
        playerTagsContainer.id = 'player-tags-container';
        document.body.appendChild(playerTagsContainer);
    }

    // State Variables
    let activeNuiDotElements = {};
    let activeContextDotElements = {};
    let activePlayerTags = {};
    let isRadialMenuVisible = false;
    let currentMenuTargetDotId = null;
    let lastHoveredContextDotPosition = null;
    let resourceName = 'core_focus';
    let latestDotDataFromLua = [];
    let hoverToOpen = true; // Default to hover mode
    let menuClearanceTimeoutId = null;
    let menuCloseOnLeaveTimeoutId = null;
    let audioPlayer = null;
    let pluginActivationTimeoutId = null;

    // High-priority position update system
    let positionUpdateQueue = [];
    let isPositionUpdateRunning = false;
    let lastFrameTime = 0;

    // State for Scrolling and Searching
    let allMenuOptions = [];
    let currentFilteredOptions = [];
    let currentScrollAngle = 0;
    let searchInput = null;
    let wheelListener = null;
    let searchListener = null;

    // Constants
    const PADDING_FOR_MENU_DIAMETER = 20;
    const DOT_UPDATE_PIXEL_THRESHOLD = 0.5;
    const MAX_VISIBLE_ITEMS = 10; // UPDATED as per your request
    const SCROLL_SENSITIVITY = 0.5;

    function getResourceName() {
        if (window.GetParentResourceName) {
            try {
                const name = window.GetParentResourceName();
                if (name) { resourceName = name; return name; }
            } catch (e) { /* silent */ }
        }
        return resourceName;
    }
    getResourceName();

    function playSound(file) {
        if (audioPlayer != null) audioPlayer.pause();
        audioPlayer = new Audio("../sounds/" + file + ".mp3");
        audioPlayer.volume = 0.2;
        audioPlayer.play().catch(() => { audioPlayer = null; });
    }

    // High-priority position update system to prevent freezing during animations
    let targetingActive = false; // Track if targeting system is active
    
    function schedulePositionUpdate(updateFunction, priority = 'normal') {
        // Only schedule updates if targeting is active
        if (!targetingActive) return;
        
        positionUpdateQueue.push({ fn: updateFunction, priority });
        if (!isPositionUpdateRunning) {
            startPositionUpdateLoop();
        }
    }

    function startPositionUpdateLoop() {
        if (isPositionUpdateRunning) return;
        isPositionUpdateRunning = true;
        
        function updateLoop(currentTime) {
            // Stop the loop immediately if targeting is no longer active
            if (!targetingActive) {
                isPositionUpdateRunning = false;
                positionUpdateQueue = []; // Clear any remaining updates
                return;
            }
            
            // Only process updates if we have work to do
            if (positionUpdateQueue.length > 0) {
                // Track performance only when we have actual updates to process
                trackPerformance();
                
                // Process high priority updates first
                const highPriorityUpdates = positionUpdateQueue.filter(u => u.priority === 'high');
                const normalUpdates = positionUpdateQueue.filter(u => u.priority === 'normal');
                
                // Clear the queue
                positionUpdateQueue = [];
                
                // Execute updates with error handling
                [...highPriorityUpdates, ...normalUpdates].forEach(update => {
                    try {
                        update.fn();
                    } catch (e) {
                        console.warn('Position update failed:', e);
                    }
                });
                
                lastFrameTime = currentTime;
            }
            
            // Keep the loop running only if targeting is active and we have work to do
            if (targetingActive && (positionUpdateQueue.length > 0 || isRadialMenuVisible || Object.keys(activeNuiDotElements).length > 0 || Object.keys(activePlayerTags).length > 0)) {
                requestAnimationFrame(updateLoop);
            } else {
                isPositionUpdateRunning = false;
            }
        }
        
        requestAnimationFrame(updateLoop);
    }

    async function postToLua(eventName, data = {}) {
        try {
            await fetch(`https://${getResourceName()}/${eventName}`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                body: JSON.stringify(data),
            });
        } catch (error) { /* silent */ }
    }

    function updateRadialMenuPosition(newScreenPos) {
        if (!targetingActive || !isRadialMenuVisible || !radialMenuContainer || !newScreenPos) return;
        
        // Use high-priority scheduling for menu position updates
        schedulePositionUpdate(() => {
            const menuViewportCenterX = newScreenPos.sx * window.innerWidth;
            const menuViewportCenterY = newScreenPos.sy * window.innerHeight;
            let menuActualDiameter = parseFloat(radialMenuContainer.style.width);
            if (isNaN(menuActualDiameter) || menuActualDiameter <= 0) {
                const itemSizeStyle = getComputedStyle(document.documentElement).getPropertyValue('--radial-item-size');
                const itemSizeNum = parseFloat(itemSizeStyle) || 70;
                const currentItemCount = allMenuOptions.length;
                let itemPlacementRadius = radialMenuContainer.classList.contains('context-active') ? 90 : 70;
                if (currentItemCount > 6) itemPlacementRadius += 10;
                if (currentItemCount >= 8) itemPlacementRadius += 11;
                if (currentItemCount <= 4) itemPlacementRadius -= 10;
                menuActualDiameter = (itemPlacementRadius * 2) + itemSizeNum + PADDING_FOR_MENU_DIAMETER;
            }
            radialMenuContainer.style.left = `${menuViewportCenterX - menuActualDiameter / 2}px`;
            radialMenuContainer.style.top = `${menuViewportCenterY - menuActualDiameter / 2}px`;

            const svgCircle = document.querySelector('#svgTextPath circle');
            if (svgCircle) {
                svgCircle.setAttribute('cx', `${menuViewportCenterX}px`);
                svgCircle.setAttribute('cy', `${menuViewportCenterY}px`);
                svgCircle.setAttribute('r', `${menuActualDiameter / 2}`);
            }
        }, 'high');
    }

    function renderOrUpdatePlayerTags(newTagsData) {
        if (!targetingActive || !playerTagsContainer) return;

        // Use high-priority scheduling for player tag updates
        schedulePositionUpdate(() => {
            const incomingTagIds = new Set();
            if (Array.isArray(newTagsData)) {
                newTagsData.forEach(tagData => {
                    if (typeof tagData.id === 'undefined' || typeof tagData.sx === 'undefined') return;
                    const tagIdStr = String(tagData.id);
                    incomingTagIds.add(tagIdStr);
                    let existingTag = activePlayerTags[tagIdStr];
                    
                    if (!existingTag) {
                        const tagElement = document.createElement('div');
                        tagElement.className = 'player-tag';
                        tagElement.dataset.tagId = tagIdStr;
                        tagElement.innerHTML = tagData.showId ? `${tagData.name} <span class="tag-id">[${tagIdStr}]</span>` : tagData.name;
                        playerTagsContainer.appendChild(tagElement);
                        activePlayerTags[tagIdStr] = { element: tagElement, sx: -1, sy: -1 };
                        existingTag = activePlayerTags[tagIdStr];
                        setTimeout(() => tagElement.classList.add('visible'), 10);
                    }

                    const positionChanged = Math.abs(tagData.sx - existingTag.sx) > 0.001 || Math.abs(tagData.sy - existingTag.sy) > 0.001;
                    if (positionChanged) {
                        existingTag.element.style.left = `${tagData.sx * 100}%`;
                        existingTag.element.style.top = `${tagData.sy * 100}%`;
                        existingTag.sx = tagData.sx;
                        existingTag.sy = tagData.sy;
                    }
                });
            }

            for (const tagIdStr in activePlayerTags) {
                if (!incomingTagIds.has(tagIdStr)) {
                    const tagElement = activePlayerTags[tagIdStr].element;
                    tagElement.classList.remove('visible');
                    setTimeout(() => tagElement.remove(), 200);
                    delete activePlayerTags[tagIdStr];
                }
            }
        }, 'high');
    }

    function renderOrUpdateDotsOnNUI(newDotsData) {
        if (!targetingActive || !nuiDotsContainer || !contextDotsContainer) return;
        const worldDots = [];
        const contextDots = [];

        if (Array.isArray(newDotsData)) {
            newDotsData.forEach(dot => dot.renderType === 'context' ? contextDots.push(dot) : worldDots.push(dot));
        }
        
        const incomingWorldDotIds = new Set();
        worldDots.forEach(newDot => {
            if (typeof newDot.id === 'undefined' || typeof newDot.sx === 'undefined' || typeof newDot.sy === 'undefined') return;
            const dotIdStr = String(newDot.id);
            incomingWorldDotIds.add(dotIdStr);
            let existingEntry = activeNuiDotElements[dotIdStr];
            let dotElement; let isNew = false;
            if (!existingEntry) {
                isNew = true;
                dotElement = document.createElement('div');
                dotElement.className = 'nui-target-dot';
                dotElement.dataset.dotId = dotIdStr;
                nuiDotsContainer.appendChild(dotElement);
                activeNuiDotElements[dotIdStr] = { element: dotElement, sx: -1, sy: -1 };
                existingEntry = activeNuiDotElements[dotIdStr];
            } else { dotElement = existingEntry.element; }

            if (newDot.isInteractable === false) dotElement.classList.add('non-interactable');
            else dotElement.classList.remove('non-interactable');

            if (existingEntry.forceColor !== newDot.forceColor) {
                dotElement.style.setProperty('--dynamic-dot-color', newDot.forceColor || '');
                existingEntry.forceColor = newDot.forceColor;
            }
            if (existingEntry.renderType !== newDot.renderType) {
                if(existingEntry.renderType) dotElement.classList.remove(`dot-type-${existingEntry.renderType.replace(/[^a-zA-Z0-9-_]/g, '-').toLowerCase()}`);
                if(newDot.renderType) dotElement.classList.add(`dot-type-${newDot.renderType.replace(/[^a-zA-Z0-9-_]/g, '-').toLowerCase()}`);
                existingEntry.renderType = newDot.renderType;
            }
            if (existingEntry.label !== newDot.label) {
                dotElement.title = newDot.label ? `${newDot.label} (ID: ${dotIdStr})` : '';
                existingEntry.label = newDot.label;
            }
            const newPixelX = newDot.sx * window.innerWidth;
            const newPixelY = newDot.sy * window.innerHeight;
            const positionChangedSignificantly = isNew || Math.abs(newPixelX - (existingEntry.sx * window.innerWidth)) >= DOT_UPDATE_PIXEL_THRESHOLD || Math.abs(newPixelY - (existingEntry.sy * window.innerHeight)) >= DOT_UPDATE_PIXEL_THRESHOLD;
            if (positionChangedSignificantly) {
                // Use high-priority scheduling for dot position updates to prevent freezing
                schedulePositionUpdate(() => {
                    dotElement.style.left = `${newDot.sx * 100}%`;
                    dotElement.style.top = `${newDot.sy * 100}%`;
                    existingEntry.sx = newDot.sx; 
                    existingEntry.sy = newDot.sy;
                    if (isRadialMenuVisible && currentMenuTargetDotId == newDot.id) {
                        updateRadialMenuPosition({ sx: newDot.sx, sy: newDot.sy });
                    }
                }, 'high');
            }
            if (isNew) {
                // Function to handle dot interaction
                const handleDotInteraction = function() {
                    const id = this.dataset.dotId;
                    if (!isRadialMenuVisible || (currentMenuTargetDotId !== null && currentMenuTargetDotId != id)) {
                        if (isRadialMenuVisible) hideRadialMenu(true);
                   
                        currentMenuTargetDotId = id;
                        postToLua('requestRadialOptions', { dotId: id });
                    }
                };
                
                if (hoverToOpen) {
                    dotElement.addEventListener('mouseover', handleDotInteraction);
                } else {
                    dotElement.addEventListener('click', handleDotInteraction);
                }
            }
        });

        for (const dotIdStr in activeNuiDotElements) {
            if (!incomingWorldDotIds.has(dotIdStr)) {
                activeNuiDotElements[dotIdStr].element?.remove();
                delete activeNuiDotElements[dotIdStr];
            }
        }

        const incomingContextDotIds = new Set();
        contextDots.forEach(newDot => {
            if (!newDot.id) return;
            incomingContextDotIds.add(newDot.id);
            let dotElement = activeContextDotElements[newDot.id];
            if (!dotElement) {
                dotElement = document.createElement('div');
                dotElement.className = 'context-dot';
                dotElement.dataset.dotId = newDot.id;
                dotElement.innerHTML = `<i class="${newDot.icon || 'fas fa-question-circle'}"></i>`;
                dotElement.title = newDot.label || 'Context Menu';
                contextDotsContainer.appendChild(dotElement);
                activeContextDotElements[newDot.id] = dotElement;
                // Function to handle context dot interaction
                const handleContextDotInteraction = function() {
                    const id = this.dataset.dotId;
                    if (!isRadialMenuVisible || (currentMenuTargetDotId !== null && currentMenuTargetDotId !== id)) {
                         if (isRadialMenuVisible) hideRadialMenu(true);
                        currentMenuTargetDotId = id;
                        const rect = this.getBoundingClientRect();
                        lastHoveredContextDotPosition = {
                            sx: (rect.left + rect.width / 2) / window.innerWidth,
                            sy: (rect.top + rect.height / 2) / window.innerHeight
                        };
                        postToLua('requestRadialOptions', { dotId: id });
                    }
                };
                
                if (hoverToOpen) {
                    dotElement.addEventListener('mouseover', handleContextDotInteraction);
                } else {
                    dotElement.addEventListener('click', handleContextDotInteraction);
                }
            }
        });
        
        for (const dotIdStr in activeContextDotElements) {
            if (!incomingContextDotIds.has(dotIdStr)) {
                activeContextDotElements[dotIdStr]?.remove();
                delete activeContextDotElements[dotIdStr];
            }
        }
    }

function renderMenuItems() {
    if (!isRadialMenuVisible) return;

    //============================ FINAL CONFIGURATION ============================
    // Adjustment for the scrolling menu with many items.
    const SCROLLING_MENU_ADJUSTMENT = -150;
    // Adjustment for the standard menu to keep its perfect alignment.
    const STANDARD_MENU_ADJUSTMENT = 0;
    //=============================================================================

    // Clear previous items from the DOM to prevent duplicates.
    radialMenuContainer.querySelectorAll('.radial-menu-item').forEach(el => el.remove());

    const isContext = radialMenuContainer.classList.contains('context-active');
    const itemCount = currentFilteredOptions.length;
    if (itemCount === 0) return;

    // --- Sizing and positioning setup ---
    let itemPlacementRadius = isContext ? 90 : 70;
    if (allMenuOptions.length > 6) itemPlacementRadius += isContext ? 15 : 10;
    if (allMenuOptions.length >= 8) itemPlacementRadius += isContext ? 20 : 11;
    if (allMenuOptions.length <= 4) itemPlacementRadius -= isContext ? 10 : 10;
    
    const overallDiameter = parseFloat(radialMenuContainer.style.width);
    const containerCenterX = overallDiameter / 2;
    const containerCenterY = overallDiameter / 2;
    const baseStartAngle = -Math.PI / 2;

    const isScrolling = radialMenuContainer.classList.contains('scroll-active');

    // --- Prepare a definitive list of items to render ---
    let itemsToRender;
    let angleStep;
    let rotationOffset = 0; // This will hold the smooth scroll offset

    if (isScrolling) {
        // --- Scrolling Menu Logic ---
        angleStep = (2 * Math.PI) / MAX_VISIBLE_ITEMS;
        const anglePerItemOnReel = (2 * Math.PI) / itemCount;
        const scrollOffset = currentScrollAngle / anglePerItemOnReel;
        const startIndex = (Math.floor(scrollOffset) % itemCount + itemCount) % itemCount;
        const subPixelOffset = scrollOffset - Math.floor(scrollOffset);
        rotationOffset = -(subPixelOffset * angleStep);

        const slice = [];
        for (let i = 0; i < MAX_VISIBLE_ITEMS; i++) {
            const itemIndex = (startIndex + i) % itemCount;
            slice.push(currentFilteredOptions[itemIndex]);
        }
        itemsToRender = slice;

    } else {
        // --- Standard Menu Logic ---
        itemsToRender = currentFilteredOptions;
        angleStep = (2 * Math.PI) / itemCount;
    }

    // --- A SINGLE, UNIFIED LOOP TO RENDER EVERY ITEM ---
    itemsToRender.forEach((itemData, index) => {
        if (!itemData || typeof itemData.key === 'undefined') return;

        // --- THIS IS THE FIX ---
        // We check if the menu is scrolling and apply the correct adjustment value.
        const adjustmentDegrees = isScrolling ? SCROLLING_MENU_ADJUSTMENT : STANDARD_MENU_ADJUSTMENT;
        const adjustmentAngle = adjustmentDegrees * (Math.PI / 180);
        const angle = baseStartAngle + adjustmentAngle + (index * angleStep) + rotationOffset;

        const menuItem = document.createElement('div');
        menuItem.className = 'radial-menu-item';
        menuItem.dataset.optionKey = itemData.key;
        menuItem.innerHTML = `<i class="${itemData.icon || 'fas fa-question-circle'}"></i><span>${itemData.label || 'Option'}</span>${itemData.isSubMenu ? '<i class="fas fa-chevron-right sub-menu-indicator"></i>' : ''}`;
        
        const itemElemX = containerCenterX + itemPlacementRadius * Math.cos(angle);
        const itemElemY = containerCenterY + itemPlacementRadius * Math.sin(angle);
        menuItem.style.left = `${itemElemX}px`;
        menuItem.style.top = `${itemElemY}px`;

        // --- Opacity Fade Logic ---
        if (isScrolling) {
            const fadeZoneCenter = Math.PI / 2; 
            const fadeZoneWidth = Math.PI / 1.5;

            let normalizedAngle = angle % (2 * Math.PI);
            if (normalizedAngle < 0) normalizedAngle += (2 * Math.PI);

            let distanceFromCenter = Math.abs(normalizedAngle - fadeZoneCenter);
            if (distanceFromCenter > Math.PI) {
                distanceFromCenter = (2 * Math.PI) - distanceFromCenter;
            }

            let opacity = 1.0;
            if (distanceFromCenter < fadeZoneWidth / 2) {
                const progress = 1.0 - (distanceFromCenter / (fadeZoneWidth / 2));
                opacity = 1.0 - progress;
            }
            menuItem.style.opacity = opacity;
        }

        // --- Click Handler ---
        menuItem.addEventListener('click', function() {
            if (this.style.opacity && parseFloat(this.style.opacity) < 0.9) return;
            playSound('select');
            const glowEffect = document.createElement('div');
            glowEffect.className = 'radial-click-glow';
            this.parentElement.appendChild(glowEffect);
            glowEffect.classList.add('animate');
            glowEffect.addEventListener('animationend', () => glowEffect.remove());
            postToLua('radialOptionSelected', { optionKey: this.dataset.optionKey, dotId: currentMenuTargetDotId });
            if (!itemData.isSubMenu) {
                hideRadialMenu();
            }
        });

        radialMenuContainer.appendChild(menuItem);

        // --- Animation Control ---
        if (!isScrolling) {
            const animationDelay = 70 + (index * 45);
            setTimeout(() => {
                menuItem.classList.add('enter-active');
            }, animationDelay);
        } else {
            if (parseFloat(menuItem.style.opacity) > 0.05) {
                menuItem.classList.add('enter-active');
            }
        }
    });
}

    function displayRadialMenu(options, baseScreenPos, forceColor, dotId) {
        if (menuClearanceTimeoutId) clearTimeout(menuClearanceTimeoutId);
        if (pluginActivationTimeoutId) clearTimeout(pluginActivationTimeoutId);

        if (!radialMenuContainer || !options || !options.length || !baseScreenPos || typeof baseScreenPos.sx === 'undefined') {
            hideRadialMenu(); return;
        }
        
        if (wheelListener) {
            radialMenuContainer.removeEventListener('wheel', wheelListener);
            wheelListener = null;
        }
        if (searchListener && searchInput) {
            searchInput.removeEventListener('input', searchListener);
            searchListener = null;
            searchInput = null;
        }

        allMenuOptions = options;
        currentFilteredOptions = options;
        currentScrollAngle = 0;

        radialMenuContainer.innerHTML = '';
        radialMenuContainer.classList.remove('scroll-active');
        
        const isContext = typeof dotId === 'string' && dotId.startsWith('context_');
        if (isContext) radialMenuContainer.classList.add('context-active');
        else radialMenuContainer.classList.remove('context-active');

        if (forceColor) {
            radialMenuContainer.style.setProperty('--dynamic-menu-color', forceColor);
            const r = parseInt(forceColor.slice(1, 3), 16);
            const g = parseInt(forceColor.slice(3, 5), 16);
            const b = parseInt(forceColor.slice(5, 7), 16);
            radialMenuContainer.style.setProperty('--dynamic-menu-color-gradient-start', `rgba(${r}, ${g}, ${b}, 0.3)`);
        } else {
            radialMenuContainer.style.removeProperty('--dynamic-menu-color');
            radialMenuContainer.style.removeProperty('--dynamic-menu-color-gradient-start');
        }

        const itemCount = allMenuOptions.length;
        let itemPlacementRadius = isContext ? 90 : 70;
        if (itemCount > 6) itemPlacementRadius += isContext ? 15 : 10;
        if (itemCount >= 8) itemPlacementRadius += isContext ? 20 : 11;
        if (itemCount <= 4) itemPlacementRadius -= isContext ? 10 : 10;

        const menuViewportCenterX = baseScreenPos.sx * window.innerWidth;
        const menuViewportCenterY = baseScreenPos.sy * window.innerHeight;
        const itemSizeStyle = getComputedStyle(document.documentElement).getPropertyValue('--radial-item-size');
        const itemSizeNum = parseFloat(itemSizeStyle) || (isContext ? 95 : 75);
        const overallDiameter = (itemPlacementRadius * 2) + itemSizeNum + PADDING_FOR_MENU_DIAMETER;

        radialMenuContainer.style.width = `${overallDiameter}px`;
        radialMenuContainer.style.height = `${overallDiameter}px`;
        radialMenuContainer.style.left = `${menuViewportCenterX - overallDiameter / 2}px`;
        radialMenuContainer.style.top = `${menuViewportCenterY - overallDiameter / 2}px`;

        const centralActionButton = document.createElement('div');
        centralActionButton.className = 'radial-menu-center-button';
        centralActionButton.innerHTML = '<i class="fas fa-times"></i>';
        centralActionButton.addEventListener('click', () => { hideRadialMenu(); postToLua('radialMenuClosedByNui', { reason: 'center_button_click' }); });
        radialMenuContainer.appendChild(centralActionButton);

        // This condition now correctly controls both sub-menu scrolling and the item limit.
        if (itemCount > MAX_VISIBLE_ITEMS) {
            radialMenuContainer.classList.add('scroll-active');

            const searchContainer = document.createElement('div');
            searchContainer.className = 'radial-menu-search-container';
            searchContainer.innerHTML = `<i class="fas fa-search"></i><input type="text" class="radial-menu-search-input" placeholder="Search...">`;
            radialMenuContainer.appendChild(searchContainer);
            searchInput = searchContainer.querySelector('.radial-menu-search-input');
            searchInput.dataset.focused = 'false';

            wheelListener = (e) => {
                e.preventDefault();
                e.stopPropagation();
                const scrollAmount = (e.deltaY > 0 ? -1 : 1) * SCROLL_SENSITIVITY * (360 / currentFilteredOptions.length) * (Math.PI / 180);
                currentScrollAngle += scrollAmount;
                requestAnimationFrame(renderMenuItems);
            };
            radialMenuContainer.addEventListener('wheel', wheelListener, { passive: false });

            searchListener = () => {
                const query = searchInput.value.toLowerCase();
                currentFilteredOptions = allMenuOptions.filter(opt => opt.label.toLowerCase().includes(query));
                currentScrollAngle = 0;
                requestAnimationFrame(renderMenuItems);
            };
            searchInput.addEventListener('input', searchListener);

            // Add focus event to enable NUI focus and prevent menu closing
            searchInput.addEventListener('focus', () => {
                postToLua('setNuiFocus', { focused: true, keepInput: true });
                searchInput.dataset.focused = 'true';
            });

            // Add blur event to restore normal behavior
            searchInput.addEventListener('blur', () => {
                postToLua('setNuiFocus', { focused: false });
                searchInput.dataset.focused = 'false';
            });

            // Prevent menu from closing when clicking on search input
            searchInput.addEventListener('click', (e) => {
                e.stopPropagation();
                if (!searchInput.dataset.focused || searchInput.dataset.focused === 'false') {
                    searchInput.focus();
                }
            });

            // Prevent menu from closing when search container is clicked
            searchContainer.addEventListener('click', (e) => {
                e.stopPropagation();
            });

            // Prevent key events from closing menu when search is focused
            searchInput.addEventListener('keydown', (e) => {
                e.stopPropagation();
                // Allow normal typing behavior
                if (e.key === 'Escape') {
                    searchInput.blur();
                    hideRadialMenu();
                    postToLua('radialMenuClosedByNui', { reason: 'escape_key' });
                }
            });

            // Don't auto-focus - let user click to focus when needed
        }

        const animationDurationVar = isContext ? '--anim-duration-slow' : '--anim-duration-medium';
        const animationDuration = parseFloat(getComputedStyle(document.documentElement).getPropertyValue(animationDurationVar).replace('s', '')) * 1000;
        
        pluginActivationTimeoutId = setTimeout(() => {
            const pluginElement = document.getElementById('plugin');
            if (pluginElement) pluginElement.style.display = 'block';
            radialMenuContainer.classList.add('is-blur-activating');
            // Ensure position updates continue during blur activation
            if (!isPositionUpdateRunning) {
                startPositionUpdateLoop();
            }
        }, animationDuration);
        
        const svgCircle = document.querySelector('#svgTextPath circle');
        if (svgCircle) {
            svgCircle.setAttribute('cx', `${menuViewportCenterX}px`);
            svgCircle.setAttribute('cy', `${menuViewportCenterY}px`);
            svgCircle.setAttribute('r', `${overallDiameter / 2}`);
        }
        
        radialMenuContainer.style.display = 'block';
        setTimeout(() => {
            radialMenuContainer.classList.add('radial-menu-container-visible');
            centralActionButton.classList.add('enter-active');
        }, 10);

       radialMenuContainer.onmouseleave = () => {
    if (isRadialMenuVisible) {
        // Don't close menu if search input is focused
        if (searchInput && searchInput.dataset.focused === 'true') {
            return;
        }
        
        // Clear any existing timeout to prevent premature closing
        if (menuCloseOnLeaveTimeoutId) clearTimeout(menuCloseOnLeaveTimeoutId);
        
        // Set a short delay before hiding the menu
        menuCloseOnLeaveTimeoutId = setTimeout(() => {
            hideRadialMenu();
            postToLua('radialMenuClosedByNui', { reason: 'mouse_leave_container' });
        }, 100); // A 250ms delay provides a good buffer
    }
};

// Add a new event listener for when the mouse re-enters the menu
radialMenuContainer.onmouseenter = () => {
    // If the mouse comes back over the menu, cancel the closing timeout
    if (menuCloseOnLeaveTimeoutId) {
        clearTimeout(menuCloseOnLeaveTimeoutId);
        menuCloseOnLeaveTimeoutId = null;
    }
};
        
        isRadialMenuVisible = true;
        renderMenuItems();
    }
    
    function hideRadialMenu(isSwitchingDot = false) {
        const currentDotIdWhenHideCalled = currentMenuTargetDotId;
    
        if (pluginActivationTimeoutId) {
            clearTimeout(pluginActivationTimeoutId);
            pluginActivationTimeoutId = null;
        }
    
        const pluginElement = document.getElementById('plugin');
        if (pluginElement) pluginElement.style.display = 'none';
    
        if (!isRadialMenuVisible && !currentMenuTargetDotId && !isSwitchingDot) return;
    
        if (menuClearanceTimeoutId) clearTimeout(menuClearanceTimeoutId);
    
        isRadialMenuVisible = false;
    
        if (radialMenuContainer) {
            radialMenuContainer.classList.remove('radial-menu-container-visible', 'context-active', 'is-blur-activating', 'scroll-active');
            radialMenuContainer.onmouseleave = null;

            if (wheelListener) {
                radialMenuContainer.removeEventListener('wheel', wheelListener);
                wheelListener = null;
            }
            if (searchInput && searchListener) {
                searchInput.removeEventListener('input', searchListener);
                searchListener = null;
                searchInput = null;
            }
            allMenuOptions = [];
            currentFilteredOptions = [];

            Array.from(radialMenuContainer.children).forEach(el => {
                el.classList.remove('enter-active');
                el.classList.add('exit-active');
            });
        }
    
        const animationDuration = parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--anim-duration-medium').replace('s','')) * 1000 || 200;
        menuClearanceTimeoutId = setTimeout(() => {
            if (radialMenuContainer && (currentMenuTargetDotId === null || currentMenuTargetDotId === currentDotIdWhenHideCalled)) {
                radialMenuContainer.innerHTML = '';
                radialMenuContainer.style.display = 'none';
            }
            if (!isSwitchingDot) {
                currentMenuTargetDotId = null;
                if (latestDotDataFromLua.length >= 0) renderOrUpdateDotsOnNUI(latestDotDataFromLua);
            }
        }, animationDuration + 50);
    }

    document.addEventListener('contextmenu', e => { if(isRadialMenuVisible){ e.preventDefault(); hideRadialMenu(); postToLua('radialMenuClosedByNui', {reason: 'context_menu'}); }});
    window.addEventListener('keydown', e => { 
        if((e.key==="Escape"||e.key==="Backspace") && isRadialMenuVisible) {
            // Don't close menu if search input is focused (unless it's Escape from search input itself)
            if (searchInput && searchInput.dataset.focused === 'true' && e.target !== searchInput) {
                return;
            }
            hideRadialMenu(); 
            postToLua('radialMenuClosedByNui', {reason: 'escape_key'}); 
        }
    });

    // Fallback system to ensure position updates never completely stop
    setInterval(() => {
        if (latestDotDataFromLua.length > 0 && !isPositionUpdateRunning) {
            startPositionUpdateLoop();
        }
    }, 1000);

    // Performance monitoring
    let performanceMetrics = {
        lastUpdateTime: Date.now(),
        updateCount: 0,
        averageUpdateTime: 0,
        samples: []
    };

    function trackPerformance() {
        const now = Date.now();
        const timeSinceLastUpdate = now - performanceMetrics.lastUpdateTime;
        
        // Only track meaningful intervals (not the first call or very long gaps)
        if (performanceMetrics.updateCount > 0 && timeSinceLastUpdate < 1000) {
            performanceMetrics.samples.push(timeSinceLastUpdate);
            
            // Keep only the last 10 samples for a rolling average
            if (performanceMetrics.samples.length > 10) {
                performanceMetrics.samples.shift();
            }
            
            // Calculate average from samples
            performanceMetrics.averageUpdateTime = performanceMetrics.samples.reduce((a, b) => a + b, 0) / performanceMetrics.samples.length;
            
            // Only warn if we have enough samples and the average is consistently high
            if (performanceMetrics.samples.length >= 5 && performanceMetrics.averageUpdateTime > 100) {
                console.warn('Position updates are slow, average:', performanceMetrics.averageUpdateTime.toFixed(1) + 'ms');
                // Reset samples to avoid spam
                performanceMetrics.samples = [];
            }
        }
        
        performanceMetrics.updateCount++;
        performanceMetrics.lastUpdateTime = now;
    }

    window.addEventListener('message', function({ data }) {
        if (!data || !data.response) return;
        switch (data.response) {
            case 'radialTargetingActivated':
                targetingActive = true;
                hoverToOpen = data.hoverToOpen !== undefined ? data.hoverToOpen : true;
                playSound('open');
                if (nuiDotsContainer) nuiDotsContainer.innerHTML = '';
                if (contextDotsContainer) contextDotsContainer.innerHTML = '';
                if (playerTagsContainer) playerTagsContainer.innerHTML = '';
                activeNuiDotElements = {};
                activeContextDotElements = {};
                activePlayerTags = {};
                hideRadialMenu();
                if (nuiDotsContainer) nuiDotsContainer.style.display = 'block';
                if (contextDotsContainer) contextDotsContainer.style.display = 'flex';
                if (playerTagsContainer) playerTagsContainer.style.display = 'block';
                latestDotDataFromLua = [];
                currentMenuTargetDotId = null;
                // Reset performance metrics when targeting starts
                performanceMetrics.samples = [];
                performanceMetrics.updateCount = 0;
                performanceMetrics.lastUpdateTime = Date.now();
                break;
            case 'radialTargetingDeactivated':
                targetingActive = false;
                // Clear the position update queue to stop any pending updates
                positionUpdateQueue = [];
                // Reset performance metrics to prevent stale data
                performanceMetrics.samples = [];
                performanceMetrics.updateCount = 0;
                performanceMetrics.lastUpdateTime = Date.now();
                hideRadialMenu();
                // Clear all active elements
                if (nuiDotsContainer) {
                    nuiDotsContainer.innerHTML = '';
                    nuiDotsContainer.style.display = 'none';
                }
                if (contextDotsContainer) {
                    contextDotsContainer.innerHTML = '';
                    contextDotsContainer.style.display = 'none';
                }
                if (playerTagsContainer) {
                    playerTagsContainer.innerHTML = '';
                    playerTagsContainer.style.display = 'none';
                }
                activeNuiDotElements = {};
                activeContextDotElements = {};
                activePlayerTags = {};
                positionUpdateQueue = [];
                isPositionUpdateRunning = false;
                if (playerTagsContainer) playerTagsContainer.style.display = 'none';
                activeNuiDotElements = {};
                activeContextDotElements = {};
                activePlayerTags = {};
                latestDotDataFromLua = [];
                currentMenuTargetDotId = null;
                break;
            case 'updatePlayerTags':
                if (targetingActive) {
                    renderOrUpdatePlayerTags(data.tags);
                }
                break;
            case 'updateDotScreenPositions':
                if (targetingActive) {
                    latestDotDataFromLua = data.dots || [];
                    renderOrUpdateDotsOnNUI(latestDotDataFromLua);
                }
                break;
            case 'forceCloseMenuDueToMovement':
                if (isRadialMenuVisible) {
                    hideRadialMenu();
                    postToLua('radialMenuClosedByNui', { reason: 'player_moved_closed' });
                }
                break;
            case 'showRadialMenu':
                if (data.dotId && data.dotId != currentMenuTargetDotId) return;
                if (data.options?.length > 0 && data.dotPosition) {
                    let positionToUse = data.dotPosition;
                    const isContext = typeof data.dotId === 'string' && data.dotId.startsWith('context_');
                    if (isContext && lastHoveredContextDotPosition) {
                        positionToUse = lastHoveredContextDotPosition;
                    }
                    displayRadialMenu(data.options, positionToUse, data.forceColor, data.dotId);
                } else {
                    hideRadialMenu();
                }
                break;
            case 'hideRadialMenu':
                hideRadialMenu();
                break;
        }
    });
});