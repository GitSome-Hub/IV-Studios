// Augmented Window Script - Wall Display System

// Listen for messages from the client
window.addEventListener('message', function(event) {
    const data = event.data;
    const type = data.type;

    switch (type) {
        case 'update':
            updateWindow(data);
            break;
        case 'hide':
            hideWindow();
            break;
    }
});

function hideWindow() {
    document.body.style.display = 'none';
}

function updateWindow(data) {
    document.body.style.display = 'block';
    
    if (data.title) {
        setWindowTitle(data.title);
    }
    
    if (data.color) {
        updateWindowColor(data.color);
    }
    
    if (data.style) {
        updateWindowStyle(data.style);
    }
    
    if (data.data) {
        setWindowData(data.data);
    }
    
    if (data.resolution) {
        adjustForResolution(data.resolution, data.wallDimensions);
    }
}

function setWindowTitle(title) {
    const titleElement = document.getElementById('windowTitle');
    if (titleElement) {
        titleElement.textContent = title || 'Information Window';
    }
}

function setWindowData(dataMap) {
    const dataContainer = document.getElementById('windowData');
    if (!dataContainer || !dataMap) return;
    
    // Get current style to determine how to render data
    const container = document.querySelector('.window-container');
    const isImageStyle = container.classList.contains('style-image');
    const isProgressStyle = container.classList.contains('style-progress');
    
    // Check if we need to rebuild (different keys or first time)
    const existingItems = dataContainer.querySelectorAll('.data-item');
    const existingKeys = Array.from(existingItems).map(item => {
        const label = item.querySelector('.data-label');
        return label ? label.textContent : '';
    });
    const newKeys = Object.keys(dataMap);
    
    const needsRebuild = existingKeys.length !== newKeys.length || 
                        !newKeys.every(key => existingKeys.includes(key));
    
    if (needsRebuild) {
        // Clear and rebuild if structure changed
        dataContainer.innerHTML = '';
        
        // Create data items from the hashmap
        Object.entries(dataMap).forEach(([key, value], index) => {
            const dataItem = document.createElement('div');
            dataItem.className = 'data-item';
            dataItem.style.animationDelay = `${index * 0.2}s`;
            dataItem.setAttribute('data-key', key);
            
            if (isImageStyle) {
                // For image style, value should be image URL
                dataItem.style.backgroundImage = `url(${value})`;
                const label = document.createElement('div');
                label.className = 'data-label image-overlay';
                label.textContent = key;
                dataItem.appendChild(label);
            } else if (isProgressStyle) {
                // For progress style, value should be 0-100
                const label = document.createElement('div');
                label.className = 'data-label';
                label.textContent = key;
                
                const progressContainer = document.createElement('div');
                progressContainer.className = 'progress-container';
                
                const progressBarBg = document.createElement('div');
                progressBarBg.className = 'progress-bar-bg';
                
                const progressBar = document.createElement('div');
                progressBar.className = 'progress-bar';
                const progressValue = Math.max(0, Math.min(100, parseFloat(value) || 0));
                progressBar.style.width = `${progressValue}%`;
                
                const progressText = document.createElement('div');
                progressText.className = 'progress-text';
                progressText.textContent = `${progressValue}%`;
                
                progressBarBg.appendChild(progressBar);
                progressContainer.appendChild(progressBarBg);
                progressContainer.appendChild(progressText);
                
                dataItem.appendChild(label);
                dataItem.appendChild(progressContainer);
            } else {
                // Default rendering
                const label = document.createElement('div');
                label.className = 'data-label';
                label.textContent = key;
                
                const valueElement = document.createElement('div');
                valueElement.className = 'data-value';
                valueElement.textContent = value;
                
                dataItem.appendChild(label);
                dataItem.appendChild(valueElement);
            }
            
            dataContainer.appendChild(dataItem);
        });
    } else {
        // Just update values without rebuilding
        Object.entries(dataMap).forEach(([key, value]) => {
            const dataItem = dataContainer.querySelector(`[data-key="${key}"]`);
            if (!dataItem) return;
            
            if (isImageStyle) {
                dataItem.style.backgroundImage = `url(${value})`;
            } else if (isProgressStyle) {
                const progressBar = dataItem.querySelector('.progress-bar');
                const progressText = dataItem.querySelector('.progress-text');
                if (progressBar && progressText) {
                    const progressValue = Math.max(0, Math.min(100, parseFloat(value) || 0));
                    progressBar.style.width = `${progressValue}%`;
                    progressText.textContent = `${progressValue}%`;
                }
            } else {
                const valueElement = dataItem.querySelector('.data-value');
                if (valueElement) {
                    valueElement.textContent = value;
                }
            }
        });
    }
}

function updateWindowColor(hexColor) {
    if (!hexColor || !/^#[0-9A-F]{6}$/i.test(hexColor)) return;

    const r = parseInt(hexColor.slice(1, 3), 16);
    const g = parseInt(hexColor.slice(3, 5), 16);
    const b = parseInt(hexColor.slice(5, 7), 16);

    const root = document.documentElement;
    root.style.setProperty('--main-color', `rgb(${r}, ${g}, ${b})`);
    root.style.setProperty('--main-color-alpha-08', `rgba(${r}, ${g}, ${b}, 0.8)`);
    root.style.setProperty('--main-color-alpha-05', `rgba(${r}, ${g}, ${b}, 0.5)`);
    root.style.setProperty('--main-color-alpha-03', `rgba(${r}, ${g}, ${b}, 0.3)`);
    root.style.setProperty('--main-color-alpha-02', `rgba(${r}, ${g}, ${b}, 0.2)`);
    root.style.setProperty('--main-color-alpha-01', `rgba(${r}, ${g}, ${b}, 0.1)`);
}

function updateWindowStyle(styleName) {
    const container = document.querySelector('.window-container');
    const dataContainer = document.getElementById('windowData');
    if (!container || !dataContainer) return;
    
    // Remove existing style classes
    container.classList.remove('style-minimal', 'style-corporate', 'style-list', 'style-basiclist', 
                              'style-basic', 'style-image', 'style-progress', 'style-cards', 'style-compact');
    
    // Add new style class if provided
    if (styleName && styleName !== 'default') {
        container.classList.add(`style-${styleName}`);
    }
}

function adjustForResolution(resolution, wallDimensions) {
    if (!resolution || !wallDimensions) return;
    
    const body = document.body;
    const root = document.documentElement;
    
    // Update body dimensions to match DUI resolution
    body.style.width = `${resolution.width}px`;
    body.style.height = `${resolution.height}px`;
    
    // Better scaling logic - less aggressive for small walls, more scaling for large walls
    const lengthScale = wallDimensions.length / 8.0; // Base length of 8 units instead of 10
    const heightScale = wallDimensions.height / 8.0; // Base height of 8 units instead of 10
    
    // Use square root scaling to be less aggressive for small walls
    const rawScale = (lengthScale + heightScale) / 2;
    const avgScale = Math.max(0.6, Math.min(2.5, 0.4 + Math.sqrt(rawScale) * 0.8)); // Better scaling curve
    
    console.log(`Window scaling: length=${wallDimensions.length}, height=${wallDimensions.height}, rawScale=${rawScale.toFixed(2)}, finalScale=${avgScale.toFixed(2)}`);
    
    // Update CSS custom properties for dynamic scaling - this makes the flex design scale properly
    root.style.setProperty('--scale-factor', avgScale);
    root.style.setProperty('--length-scale', lengthScale);
    root.style.setProperty('--height-scale', heightScale);
}



document.addEventListener('DOMContentLoaded', function() {
    
    document.body.style.display = 'none';

});