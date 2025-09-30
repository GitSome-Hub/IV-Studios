let currentAnnouncement = null;
let progressInterval = null;
let hideTimeout = null;
let debugMode = false; // Will be set from lua config

// Debug functions for NUI
function debugLog(...args) {
    if (debugMode) {
        console.log('[FS-Government NUI]', ...args);
    }
}

function debugError(...args) {
    if (debugMode) {
        console.error('[FS-Government NUI ERROR]', ...args);
    }
}

function debugWarn(...args) {
    if (debugMode) {
        console.warn('[FS-Government NUI WARN]', ...args);
    }
}

// Fix ResizeObserver errors
let resizeObserverTimer = null;
const originalResizeObserver = window.ResizeObserver;
window.ResizeObserver = class extends originalResizeObserver {
    constructor(callback) {
        const wrappedCallback = (entries, observer) => {
            if (resizeObserverTimer) clearTimeout(resizeObserverTimer);
            resizeObserverTimer = setTimeout(() => {
                try {
                    callback(entries, observer);
                } catch (e) {
                    if (e.message !== 'ResizeObserver loop limit exceeded') {
                        debugError('ResizeObserver error:', e);
                    }
                }
            }, 16); // Debounce to next animation frame
        };
        super(wrappedCallback);
    }
};

window.addEventListener('message', function(event) {
    const data = event.data;

    switch(data.action) {
        case 'setDebugMode':
            debugMode = data.debug;
            debugLog('Debug mode set to:', debugMode);
            break;
        case 'showAnnouncement':
            showAnnouncement(data.data);
            break;
        case 'hideAnnouncement':
            hideAnnouncement();
            break;
        case 'showPermitDocument':
            showPermitDocument(data.permit, data.isOwner, data.shownBy);
            break;
    }
});

function showAnnouncement(data) {
    // Clear any existing announcement
    if (currentAnnouncement) {
        hideAnnouncement();
    }
    
    currentAnnouncement = data;
    
    const container = document.getElementById('announcement-container');
    const content = document.getElementById('announcement-content');
    const icon = document.getElementById('announcement-icon');
    const title = document.getElementById('announcement-title');
    const message = document.getElementById('announcement-message');
    const timestamp = document.getElementById('announcement-timestamp');
    const progressBar = document.getElementById('progress-bar');
    
    // Set content
    title.textContent = data.title;
    message.textContent = data.message;
    icon.className = data.icon;
    
    // Set timestamp with better formatting
    const now = new Date();
    timestamp.textContent = now.toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: true
    });
    
    // Apply type-specific styling
    content.className = `announcement-content ${data.type}`;
    
    // Apply custom background if provided, keeping it clean
    if (data.background) {
        content.style.background = data.background;
    }
    
    // Reset progress bar
    progressBar.style.width = '100%';
    
    // Show the announcement
    container.classList.remove('hidden');
    container.classList.add('show');
    
    // Play sound if enabled
    if (data.sound) {
        playNotificationSound(data.type);
    }
    
    // Start progress bar animation
    startProgressBar(data.duration);
    
    // Auto-hide after duration
    hideTimeout = setTimeout(() => {
        hideAnnouncement();
    }, data.duration);
}

function hideAnnouncement() {
    const container = document.getElementById('announcement-container');
    
    container.classList.remove('show');
    container.classList.add('hidden');
    
    // Clear intervals and timeouts
    if (progressInterval) {
        clearInterval(progressInterval);
        progressInterval = null;
    }
    
    if (hideTimeout) {
        clearTimeout(hideTimeout);
        hideTimeout = null;
    }
    
    currentAnnouncement = null;
}

function startProgressBar(duration) {
    const progressBar = document.getElementById('progress-bar');
    let width = 100;
    const decrement = 100 / (duration / 100);
    
    progressInterval = setInterval(() => {
        width -= decrement;
        if (width <= 0) {
            width = 0;
            clearInterval(progressInterval);
            progressInterval = null;
        }
        progressBar.style.width = width + '%';
    }, 100);
}

function playNotificationSound(type) {
    try {
        const audioContext = new (window.AudioContext || window.webkitAudioContext)();
        
        const frequencies = {
            government: [440, 554, 659],
            election: [523, 659, 784],
            defcon: [200, 250, 300],
            emergency: [800, 600, 400],
            law_enforcement: [330, 415, 523],
            public_service: [392, 494, 587]
        };
        
        const freq = frequencies[type] || frequencies.government;
        
        freq.forEach((frequency, index) => {
            setTimeout(() => {
                const oscillator = audioContext.createOscillator();
                const gainNode = audioContext.createGain();
                
                oscillator.connect(gainNode);
                gainNode.connect(audioContext.destination);
                
                oscillator.frequency.value = frequency;
                oscillator.type = 'sine';
                
                gainNode.gain.setValueAtTime(0.1, audioContext.currentTime);
                gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.3);
                
                oscillator.start(audioContext.currentTime);
                oscillator.stop(audioContext.currentTime + 0.3);
            }, index * 200);
        });
    } catch (error) {
        // Fallback - no sound if AudioContext fails
        debugLog('Audio context not available');
    }
}


// Prevent right-click context menu
document.addEventListener('contextmenu', function(event) {
    event.preventDefault();
});

// Handle window blur/focus for better performance
window.addEventListener('blur', function() {
    if (progressInterval) {
        clearInterval(progressInterval);
        progressInterval = null;
    }
});

window.addEventListener('focus', function() {
    if (currentAnnouncement && !progressInterval) {
        const progressBar = document.getElementById('progress-bar');
        const currentWidth = parseFloat(progressBar.style.width) || 100;
        const remainingTime = (currentWidth / 100) * currentAnnouncement.duration;
        
        if (remainingTime > 0) {
            startProgressBar(remainingTime);
        }
    }
});

// ================================
// PERMIT DOCUMENT FUNCTIONS
// ================================

// Enhanced date formatting with better debugging
function formatDate(dateString) {
    debugLog('formatDate called with:', dateString, 'Type:', typeof dateString);
    
    if (!dateString) {
        debugLog('No date string provided');
        return 'Unknown Date';
    }
    
    try {
        let date;
        
        // Handle various date formats
        if (typeof dateString === 'number' || !isNaN(dateString)) {
            // Handle timestamp (milliseconds or seconds)
            const timestamp = parseInt(dateString);
            // If timestamp is in seconds, convert to milliseconds
            date = new Date(timestamp < 10000000000 ? timestamp * 1000 : timestamp);
            debugLog('Parsed timestamp:', timestamp, 'to date:', date);
        } else if (typeof dateString === 'string') {
            // Handle special cases
            if (dateString.toLowerCase() === 'no expiry' || dateString.toLowerCase() === 'never') {
                return 'No Expiry';
            }
            
            // Handle MySQL datetime format (YYYY-MM-DD HH:MM:SS)
            if (dateString.match(/^\d{4}-\d{2}-\d{2}(\s\d{2}:\d{2}:\d{2})?$/)) {
                date = new Date(dateString);
                debugLog('Parsed MySQL datetime:', dateString, 'to date:', date);
            }
            // Handle slash formats
            else if (dateString.includes('/')) {
                const parts = dateString.split('/');
                if (parts.length === 3) {
                    // Try MM/DD/YYYY first
                    date = new Date(parts[2], parts[0] - 1, parts[1]);
                    // If invalid, try DD/MM/YYYY
                    if (isNaN(date.getTime())) {
                        date = new Date(parts[2], parts[1] - 1, parts[0]);
                    }
                    debugLog('Parsed slash format:', dateString, 'to date:', date);
                }
            }
            // Handle dash formats
            else if (dateString.includes('-')) {
                date = new Date(dateString);
                debugLog('Parsed dash format:', dateString, 'to date:', date);
            }
            // Try general parsing
            else {
                date = new Date(dateString);
                debugLog('General date parsing:', dateString, 'to date:', date);
            }
        } else {
            date = new Date(dateString);
            debugLog('Direct date conversion:', dateString, 'to date:', date);
        }
        
        // Check if date is valid
        if (!date || isNaN(date.getTime())) {
            debugLog('Invalid date result:', date);
            return 'Unknown Date';
        }
        
        // Format to human-readable format
        const formatted = date.toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        });
        
        debugLog('Final formatted date:', formatted);
        return formatted;
    } catch (e) {
        debugError('Date formatting error:', e, 'for input:', dateString);
        return 'Unknown Date';
    }
}

function formatDateTime(dateTimeString) {
    if (!dateTimeString) return 'Unknown Date';
    
    try {
        const date = new Date(dateTimeString);
        
        if (isNaN(date.getTime())) {
            return formatDate(dateTimeString);
        }
        
        return date.toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            hour12: true
        });
    } catch (e) {
        debugError('DateTime formatting error:', e);
        return formatDate(dateTimeString);
    }
}

// Helper function to extract data from permit object with multiple possible keys
function getPermitValue(permit, possibleKeys, defaultValue = null) {
    for (const key of possibleKeys) {
        if (permit[key] && permit[key] !== '' && permit[key] !== 'Unknown' && permit[key] !== 'null') {
            return permit[key];
        }
    }
    return defaultValue;
}

function showPermitDocument(permit, isOwner, shownBy) {
    const container = document.getElementById('permit-document-container');
    const page = document.querySelector('.permit-document-page');
    
    // Debug: Log the permit object to console
    debugLog('Permit data received:', permit);
    debugLog('All permit keys:', Object.keys(permit));
    
    // Set permit data status for styling
    page.setAttribute('data-status', permit.status);
    
    // Update document content
    document.getElementById('permit-title').textContent = `${permit.permit_type.replace('_', ' ').toUpperCase()} PERMIT`;
    document.getElementById('permit-number').textContent = permit.permit_number || 'PER-000000';
    
    // Try multiple possible property names for issue date
    const issueDate = getPermitValue(permit, [
        'issued_date',
        'formatted_issued_date', 
        'issue_date',
        'created_at',
        'date_issued',
        'issued_at',
        'createdAt'
    ]);
    
    let formattedIssueDate;
    if (issueDate) {
        formattedIssueDate = formatDate(issueDate);
        // If formatDate returns 'Unknown Date', use current date
        if (formattedIssueDate === 'Unknown Date') {
            formattedIssueDate = new Date().toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'long',
                day: 'numeric'
            });
        }
    } else {
        // No issue date found, use current date
        formattedIssueDate = new Date().toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        });
    }
    
    document.getElementById('permit-issue-date').textContent = formattedIssueDate;
    document.getElementById('permit-type').textContent = permit.permit_type.replace('_', ' ').toUpperCase();
    
    // Handle expiry date
    const expiryDate = getPermitValue(permit, [
        'expiry_date',
        'formatted_expiry_date',
        'expires_at',
        'expiration_date'
    ]);
    document.getElementById('permit-expiry-date').textContent = expiryDate ? formatDate(expiryDate) : 'No Expiry';
    
    // Handle holder name
    const holderName = getPermitValue(permit, [
        'holder_name',
        'owner_name',
        'citizen_name',
        'player_name'
    ], 'Unknown Holder');
    document.getElementById('permit-holder-name').textContent = holderName;
    
    document.getElementById('permit-status').textContent = permit.status ? permit.status.toUpperCase() : 'ACTIVE';
    
    // Handle description
    const description = getPermitValue(permit, [
        'description',
        'permit_description',
        'details'
    ], 'This permit authorizes the holder to engage in the activities specified herein, subject to all applicable laws, regulations, and conditions set forth by the Government of Los Santos.');
    document.getElementById('permit-description').textContent = description;
    
    // First try to get the issuing officer's name (not the holder's name)
    let officerName = getPermitValue(permit, [
        'issued_by_name',
        'created_by_name',
        'officer_name',
        'issuing_officer_name',
        'authorizing_officer'
    ]);
    
    debugLog('First attempt officer name:', officerName);
    
    // If no character name found, try all officer fields without filtering
    if (!officerName || officerName === 'Government Official') {
        officerName = getPermitValue(permit, [
            'issuing_officer',
            'issued_by',
            'created_by',
            'issuedBy',
            'createdBy',
            'authorizedBy',
            'signedBy'
        ]);
        
        debugLog('Fallback officer name:', officerName);
        
        // Only filter out obvious identifiers but be more lenient
        if (officerName && 
            (officerName.length > 50 || // Very long strings
             /^[a-f0-9]{16,}$/.test(officerName) || // Looks like a long hash
             officerName.startsWith('steam:'))) { // Steam IDs
            debugLog('Filtered out identifier:', officerName);
            officerName = 'Government Official';
        }
        
        // If still no name, use default
        if (!officerName) {
            officerName = 'Government Official';
        }
        
        debugLog('Final fallback name:', officerName);
    }
    
    debugLog('Officer name found:', officerName);
    debugLog('Issue date found:', formattedIssueDate);
    
    // Automatic signature - use the issuing officer's name with automatic signature styling
    const issuedByElement = document.getElementById('permit-issued-by');
    
    // Ensure we have a valid date for signature - never show "Unknown Date"
    const signatureDate = (formattedIssueDate && formattedIssueDate !== 'Unknown Date') ? 
        formattedIssueDate : 
        new Date().toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        });
    
    // Create a stylized signature that sits ON the signature line
    issuedByElement.innerHTML = `
        <div class="signature-container">
            <div class="signature-line-with-text">
                <span class="signature-style">${officerName}</span>
            </div>
            <div class="signature-date">Signed on ${signatureDate}</div>
        </div>
    `;
    
    // Format current generation date
    const currentDate = new Date().toLocaleDateString('en-US', { 
        year: 'numeric', 
        month: 'long', 
        day: 'numeric' 
    });
    const generationDate = permit.current_date ? formatDate(permit.current_date) : currentDate;
    document.getElementById('document-generation-date').textContent = generationDate;
    
    // Handle "shown by" information
    const shownByElement = document.getElementById('permit-shown-by');
    if (!isOwner && shownBy) {
        document.getElementById('shown-by-name').textContent = shownBy;
        shownByElement.classList.remove('hidden');
    } else {
        shownByElement.classList.add('hidden');
    }
    
    // Apply status-specific styling to status cell
    const statusCell = document.getElementById('permit-status');
    statusCell.className = 'value-cell';
    
    if (permit.status === 'expired') {
        statusCell.style.color = '#e74c3c';
        statusCell.style.fontWeight = 'bold';
    } else if (permit.status === 'suspended') {
        statusCell.style.color = '#f39c12';
        statusCell.style.fontWeight = 'bold';
    } else if (permit.status === 'revoked') {
        statusCell.style.color = '#e74c3c';
        statusCell.style.fontWeight = 'bold';
        statusCell.style.textDecoration = 'line-through';
    } else {
        statusCell.style.color = '#27ae60';
        statusCell.style.fontWeight = 'bold';
    }
    
    // Show the document
    container.classList.remove('hidden');
    
    // Add fade-in animation
    setTimeout(() => {
        page.style.opacity = '0';
        page.style.transform = 'scale(0.9)';
        page.style.transition = 'all 0.3s ease-in-out';
        
        setTimeout(() => {
            page.style.opacity = '1';
            page.style.transform = 'scale(1)';
        }, 50);
    }, 10);
}

function closePermitDocument() {
    const container = document.getElementById('permit-document-container');
    const page = document.querySelector('.permit-document-page');
    
    // Add fade-out animation
    page.style.opacity = '0';
    page.style.transform = 'scale(0.9)';
    page.style.transition = 'all 0.3s ease-in-out';
    
    setTimeout(() => {
        container.classList.add('hidden');
        
        // Reset styles
        page.style.opacity = '';
        page.style.transform = '';
        page.style.transition = '';
        
        // Send callback to close NUI focus
        try {
            fetch(`https://${GetParentResourceName()}/closePermitDocument`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({})
            }).catch(function(error) {
                // Ignore fetch errors in browser environment
                debugLog('NUI callback failed (expected in browser):', error);
            });
        } catch (error) {
            debugLog('NUI callback not available (expected in browser):', error);
        }
    }, 300);
}

// Allow ESC key to close permit document
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        const container = document.getElementById('permit-document-container');
        if (!container.classList.contains('hidden')) {
            closePermitDocument();
        }
    }
});

// Utility function to get parent resource name (for standalone testing)
function GetParentResourceName() {
    // Check if we're in FiveM environment and GetParentResourceName exists as a native function
    if (typeof window !== 'undefined' && 
        typeof window.GetParentResourceName === 'function' && 
        window.GetParentResourceName !== GetParentResourceName) { // Prevent self-reference
        try {
            return window.GetParentResourceName();
        } catch (e) {
            debugLog('GetParentResourceName failed, using fallback');
            return 'fs-government';
        }
    }
    // Fallback for testing - return static name to prevent recursion
    return 'fs-government';
}