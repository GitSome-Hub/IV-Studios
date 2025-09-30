let currentVehicles = [];
let selectedVehicle = null;
let selectedColor = null;
let categories = [];
let config = null;
let playerData = null;

// Listen for NUI messages from FiveM
window.addEventListener('message', function(event) {
    const data = event.data;
    if (!data.type) return;

    switch (data.type) {
        case "ui":
            if (data.status) {
                document.querySelector('.container').classList.add('visible');
                if (data.vehicles && Array.isArray(data.vehicles)) {
                    currentVehicles = data.vehicles;
                    categories = data.categories || [];
                    config = data.config || null;
                    playerData = data.player || null;
                    
                    // Update UI texts with config values
                    if (config) {
                        updateUITexts(config);
                    }
                    
                    if (data.dealership) {
                        document.getElementById('dealershipName').textContent = data.dealership;
                    }
                    
                    updatePlayerInfo();
                    renderCategories();
                    renderVehicles(currentVehicles);
                }
            } else {
                document.querySelector('.container').classList.remove('visible');
            }
            break;
        case "purchaseResponse":
            showNotification(data.message, data.success);
            if (data.success) {
                setTimeout(() => {
                    closeVehicleDetails();
                }, 2000);
            }
            break;
        case "testDriveCountdown":
            if (data.show) {
                showTestDriveCountdown(data.duration);
            } else {
                hideTestDriveCountdown();
            }
            break;
        case "updateCountdown":
            updateCountdown(data.timeLeft);
            if (data.timeLeft <= 0) {
                hideTestDriveCountdown();
            }
            break;
        case "updateMoney":
            if (data.money) {
                document.getElementById('playerMoney').textContent = formatPrice(parseInt(data.money) || 0);
            }
            break;
    }
});

// Update UI texts with config values
function updateUITexts(config) {
    if (!config || !config.ui) return;

    // Update welcome text
    document.querySelector('.welcome-text').textContent = config.ui.labels.welcomeText;

    // Update search placeholder
    document.getElementById('searchInput').placeholder = config.ui.labels.searchPlaceholder;

    // Update filter options
    document.getElementById('categoryFilter').firstElementChild.textContent = config.ui.filters.allCategories;
    const priceSort = document.getElementById('priceSort');
    priceSort.firstElementChild.textContent = config.ui.filters.sortByPrice;
    priceSort.children[1].textContent = config.ui.filters.priceLowToHigh;
    priceSort.children[2].textContent = config.ui.filters.priceHighToLow;

    // Update section title
    document.querySelector('.section-title').textContent = config.ui.labels.allVehicles;

    // Update vehicle customization title
    document.querySelector('.vehicle-customization h3').textContent = config.ui.labels.vehicleCustomization;

    // Update color selection title
    document.querySelector('.color-selection h4').textContent = config.ui.labels.availableColors;

    // Update buttons
    document.getElementById('testDriveButton').innerHTML = `
        <i class="fas fa-key"></i>
        ${config.ui.buttons.testDrive}
    `;
    
    // Update purchase button default text
    const purchaseBtn = document.getElementById('purchaseButton');
    purchaseBtn.dataset.selectColorText = config.ui.buttons.selectColor;
    purchaseBtn.dataset.purchaseText = config.ui.buttons.purchase;
    purchaseBtn.innerHTML = `<i class="fas fa-palette"></i> ${config.ui.buttons.selectColor}`;

    // Update close button
    document.getElementById('closeBtn').title = config.ui.buttons.close;

    // Update specs labels
    document.querySelector('.spec-item:nth-child(1) span').textContent = config.ui.specs.power;
    document.querySelector('.spec-item:nth-child(2) span').textContent = config.ui.specs.topSpeed;
    document.querySelector('.spec-item:nth-child(3) span').textContent = config.ui.specs.acceleration;

    // Update test drive countdown label
    document.querySelector('.countdown-label').textContent = config.ui.labels.testDriveDuration;
}

// Update player information
function updatePlayerInfo() {
    if (playerData) {
        document.getElementById('playerName').textContent = playerData.name || 'Unknown Player';
        document.getElementById('playerMoney').textContent = formatPrice(parseInt(playerData.money) || 0);
        if (playerData.avatar) {
            document.getElementById('playerAvatar').src = playerData.avatar;
        }
    }
}

// Format price according to currency configuration
function formatPrice(price) {
    if (!config || !config.currency) return `$${price.toLocaleString()}`;
    const { symbol, position, thousandSeparator, decimalSeparator, decimals } = config.currency;
    let formattedNumber = price.toFixed(decimals);
    const [intPart, decPart] = formattedNumber.split('.');
    formattedNumber = intPart.replace(/\B(?=(\d{3})+(?!\d))/g, thousandSeparator);
    if (decPart) {
        formattedNumber = formattedNumber + decimalSeparator + decPart;
    }
    return position === 'before' ? 
        `${symbol}${formattedNumber}` : 
        `${formattedNumber}${symbol}`;
}

// Render categories with animation
function renderCategories() {
    const container = document.getElementById('categoriesContainer');
    container.innerHTML = '';

    categories.forEach((category, index) => {
        const btn = createCategoryButton(
            category.id, 
            category.label, 
            category.icon, 
            category.id === 'all'
        );
        
        setTimeout(() => {
            btn.classList.add('visible');
        }, index * 100);
        
        container.appendChild(btn);
    });
    
    populateCategoryFilter();
}

function createCategoryButton(id, label, icon, isActive = false) {
    const button = document.createElement('button');
    button.className = `category-btn${isActive ? ' active' : ''}`;
    button.setAttribute('data-category', id);
    button.innerHTML = `
        <i class="fas fa-${icon}"></i>
        <span>${label}</span>
    `;
    
    button.addEventListener('click', () => {
        document.querySelectorAll('.category-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        button.classList.add('active');
        
        document.querySelector('.section-title').textContent = 
            id === 'all' ? config.ui.labels.allVehicles : label;
        
        const filtered = id === 'all' 
            ? currentVehicles 
            : currentVehicles.filter(v => v.category === id);
        
        renderVehicles(filtered);
    });

    return button;
}

// Render vehicles with animation
function renderVehicles(vehicles) {
    const grid = document.getElementById('vehiclesGrid');
    grid.innerHTML = '';

    if (!vehicles || vehicles.length === 0) {
        grid.innerHTML = '<p class="no-vehicles">No vehicles found</p>';
        return;
    }

    vehicles.forEach((vehicle, index) => {
        const card = document.createElement('div');
        card.className = 'vehicle-card';
        
        let tagHtml = '';
        if (vehicle.tag) {
            tagHtml = `<div class="vehicle-tag tag-${vehicle.tag.toLowerCase()}">${vehicle.tag}</div>`;
        }
        
        card.innerHTML = `
            ${tagHtml}
            <img src="${vehicle.image}" alt="${vehicle.name}" onerror="this.src='https://via.placeholder.com/400x225?text=Vehicle+Image'">
            <div class="vehicle-card-content">
                <h3>${vehicle.name}</h3>
                <p class="price">${formatPrice(vehicle.price)}</p>
                <div class="card-buttons">
                    <button class="details-btn" onclick="showVehicleDetails(${JSON.stringify(vehicle).replace(/"/g, '&quot;')})">
                        <i class="fas fa-info-circle"></i>
                        ${config.ui.buttons.details}
                    </button>
                    <button class="quick-purchase-btn" onclick="showVehicleDetails(${JSON.stringify(vehicle).replace(/"/g, '&quot;')})">
                        <i class="fas fa-shopping-cart"></i>
                        ${config.ui.buttons.purchase}
                    </button>
                </div>
            </div>
        `;
        grid.appendChild(card);
        
        requestAnimationFrame(() => {
            setTimeout(() => {
                card.classList.add('visible');
            }, index * 50);
        });
    });
}

// Show vehicle details
function showVehicleDetails(vehicle) {
    selectedVehicle = vehicle;
    selectedColor = null;
    
    document.getElementById('detailImage').src = vehicle.image;
    document.getElementById('detailName').textContent = vehicle.name;
    document.getElementById('detailPrice').textContent = formatPrice(vehicle.price);
    
    document.getElementById('specPower').textContent = vehicle.specs?.power || '--';
    document.getElementById('specSpeed').textContent = vehicle.specs?.topSpeed || '--';
    document.getElementById('specAccel').textContent = vehicle.specs?.acceleration || '--';
    
    const colorGrid = document.getElementById('colorGrid');
    colorGrid.innerHTML = '';
    
    if (vehicle.colors && Array.isArray(vehicle.colors)) {
        vehicle.colors.forEach((color, index) => {
            const colorBtn = document.createElement('button');
            colorBtn.className = 'color-option';
            colorBtn.style.backgroundColor = color.hex;
            colorBtn.title = color.name;
            colorBtn.addEventListener('click', () => selectColor(color.hex, colorBtn));
            colorGrid.appendChild(colorBtn);
            
            setTimeout(() => {
                colorBtn.style.transform = 'scale(1)';
                colorBtn.style.opacity = '1';
            }, index * 50);
        });
    }
    
    const purchaseBtn = document.getElementById('purchaseButton');
    purchaseBtn.disabled = true;
    purchaseBtn.innerHTML = `<i class="fas fa-palette"></i> ${config.ui.buttons.selectColor}`;
    
    document.getElementById('modalBackdrop').classList.add('visible');
    document.getElementById('vehicleDetails').classList.add('visible');
}

// Select color
function selectColor(color, button) {
    selectedColor = color;
    
    const purchaseBtn = document.getElementById('purchaseButton');
    purchaseBtn.disabled = false;
    purchaseBtn.innerHTML = `<i class="fas fa-shopping-cart"></i> ${config.ui.buttons.purchase}`;
    
    document.querySelectorAll('.color-option').forEach(btn => {
        btn.classList.remove('selected');
    });
    button.classList.add('selected');
}

// Purchase vehicle
function purchaseVehicle() {
    if (!selectedColor) {
        showNotification(config.ui.notifications.selectColor, false);
        return;
    }
    
    if (selectedVehicle && selectedColor) {
        fetch(`https://${GetParentResourceName()}/purchaseVehicle`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                vehicle: {
                    ...selectedVehicle,
                    selectedColor: selectedColor
                }
            })
        });
    }
}

// Close vehicle details
function closeVehicleDetails() {
    document.getElementById('modalBackdrop').classList.remove('visible');
    document.getElementById('vehicleDetails').classList.remove('visible');
    selectedVehicle = null;
    selectedColor = null;
}

// Show notification
function showNotification(message, success = true) {
    const notification = document.getElementById('notification');
    
    notification.className = 'notification';
    notification.classList.add(success ? 'success' : 'error');
    
    notification.innerHTML = `
        <div class="notification-content">
            <i class="fas ${success ? 'fa-check-circle' : 'fa-times-circle'} notification-icon"></i>
            <span class="notification-text">${message}</span>
        </div>
        <button class="close-btn" onclick="hideNotification()">${config.ui.buttons.close}</button>
    `;
    
    notification.classList.add('visible');
    
    setTimeout(() => {
        hideNotification();
    }, 3000);
}

function hideNotification() {
    const notification = document.getElementById('notification');
    notification.classList.remove('visible');
}

// Test drive
function startTestDrive() {
    if (!selectedVehicle) {
        showNotification(config.ui.notifications.selectVehicle, false);
        return;
    }

    fetch(`https://${GetParentResourceName()}/testDrive`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            vehicle: selectedVehicle
        })
    });

    closeVehicleDetails();
    closeUI();
}

// Test Drive Countdown UI
function showTestDriveCountdown(duration) {
    hideTestDriveCountdown();
    
    const countdown = document.createElement('div');
    countdown.className = 'test-drive-countdown';
    countdown.id = 'testDriveCountdown';
    countdown.innerHTML = `
        <div class="countdown-timer" id="countdownTimer">${duration}</div>
        <div class="countdown-label">${config.ui.labels.testDriveDuration}</div>
        <div class="countdown-progress">
            <div class="countdown-progress-bar" id="countdownProgress"></div>
        </div>
    `;
    
    document.body.appendChild(countdown);
    
    requestAnimationFrame(() => {
        countdown.classList.add('visible');
        const progressBar = document.getElementById('countdownProgress');
        progressBar.style.transition = `width ${duration}s linear`;
        progressBar.style.width = '0%';
    });
}

function updateCountdown(timeLeft) {
    const timer = document.getElementById('countdownTimer');
    const countdown = document.getElementById('testDriveCountdown');
    
    if (timer && countdown && countdown.classList.contains('visible')) {
        timer.textContent = timeLeft;
    }
}

function hideTestDriveCountdown() {
    const countdown = document.getElementById('testDriveCountdown');
    if (countdown) {
        countdown.classList.remove('visible');
        setTimeout(() => {
            if (countdown && countdown.parentNode) {
                countdown.parentNode.removeChild(countdown);
            }
        }, 300);
    }
}

// Close UI
function closeUI() {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST'
    }).catch(err => console.error(err));
    
    document.querySelector('.container').classList.remove('visible');
    selectedVehicle = null;
    selectedColor = null;
    closeVehicleDetails();
}

// Filter functionality
function populateCategoryFilter() {
    const categoryFilter = document.getElementById('categoryFilter');
    categoryFilter.innerHTML = `<option value="">${config.ui.filters.allCategories}</option>`;
    
    categories.forEach(category => {
        if (category.id !== 'all') {
            const option = document.createElement('option');
            option.value = category.id;
            option.textContent = category.label;
            categoryFilter.appendChild(option);
        }
    });
}

function applyFilters() {
    const categoryValue = document.getElementById('categoryFilter').value;
    const sortValue = document.getElementById('priceSort').value;
    const searchValue = document.getElementById('searchInput').value.toLowerCase();
    
    let filtered = [...currentVehicles];
    
    if (categoryValue) {
        filtered = filtered.filter(v => v.category === categoryValue);
    }
    
    if (searchValue) {
        filtered = filtered.filter(v => 
            v.name.toLowerCase().includes(searchValue) ||
            v.category.toLowerCase().includes(searchValue)
        );
    }
    
    if (sortValue) {
        filtered.sort((a, b) => {
            return sortValue === 'asc' ? 
                a.price - b.price : 
                b.price - a.price;
        });
    }
    
    renderVehicles(filtered);
}

// Event Listeners
document.addEventListener('keyup', function(event) {
    if (event.key === 'Escape') {
        closeUI();
    }
});

document.getElementById('categoryFilter').addEventListener('change', applyFilters);
document.getElementById('priceSort').addEventListener('change', applyFilters);
document.getElementById('searchInput').addEventListener('input', applyFilters);
document.getElementById('closeDetails').addEventListener('click', closeVehicleDetails);
document.getElementById('closeNotification').addEventListener('click', hideNotification);
document.getElementById('purchaseButton').addEventListener('click', purchaseVehicle);
document.getElementById('testDriveButton').addEventListener('click', startTestDrive);