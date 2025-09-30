// Augmented Border Script - Modern Redesign

// Listen for messages from the client
window.addEventListener('message', function (event) {
    const data = event.data;
    const type = data.type;

    switch (type) {
        case 'update':
            updateBorder(data);
            break;
        case 'hide':
            hideBorder();
            break;
    }
});

function hideBorder() {
    document.body.style.display = 'none';
}

function updateBorder(data) {
    document.body.style.display = 'block';
    if (data.name) {
        setLocationName(data.name);
    }
    if (data.color) {
        updateBorderColor(data.color);
    }
    if (data.height) {
        adjustForHeight(data.height);
    }
    if (data.resolution) {
        adjustForResolution(data.resolution, data.wallDimensions);
    }
}

function setLocationName(name) {
    const locationElement = document.getElementById('locationName');
    if (locationElement) {
        locationElement.textContent = name || 'Unknown Location';
    }
}

function updateBorderColor(hexColor) {
    if (!hexColor || !/^#[0-9A-F]{6}$/i.test(hexColor)) return;

    const r = parseInt(hexColor.slice(1, 3), 16);
    const g = parseInt(hexColor.slice(3, 5), 16);
    const b = parseInt(hexColor.slice(5, 7), 16);

    const root = document.documentElement;
    root.style.setProperty('--main-color', `rgb(${r}, ${g}, ${b})`);
    root.style.setProperty('--main-color-alpha-08', `rgba(${r}, ${g}, ${b}, 0.8)`);
    root.style.setProperty('--main-color-alpha-05', `rgba(${r}, ${g}, ${b}, 0.5)`);
    root.style.setProperty('--main-color-alpha-02', `rgba(${r}, ${g}, ${b}, 0.2)`);
    root.style.setProperty('--main-color-alpha-01', `rgba(${r}, ${g}, ${b}, 0.1)`);
}

function adjustForHeight(height) {
    const locationName = document.querySelector('.location-name');

    if (locationName && height) {
        // Scale font size based on wall height - bigger walls get bigger text
        const baseFontSize = Math.max(80, Math.min(300, height * 8));
        locationName.style.fontSize = `${baseFontSize}px`;

        // Adjust letter spacing based on height
        const letterSpacing = Math.max(0.05, Math.min(0.2, height * 0.01));
        locationName.style.letterSpacing = `${letterSpacing}em`;
    }
}

function adjustForResolution(resolution, wallDimensions) {
    if (!resolution || !wallDimensions) return;

    const body = document.body;
    const root = document.documentElement;

    // Update body dimensions to match DUI resolution exactly
    body.style.width = `${resolution.width}px`;
    body.style.height = `${resolution.height}px`;

    // Calculate scale factor based on resolution and wall dimensions
    const baseResolution = { width: 1920, height: 1080 }; // Reference resolution
    const baseWallSize = { length: 10.0, height: 5.0 }; // Reference wall size
    
    // Calculate scaling factors for both dimensions
    const resolutionScaleX = resolution.width / baseResolution.width;
    const resolutionScaleY = resolution.height / baseResolution.height;
    const wallScaleX = wallDimensions.length / baseWallSize.length;
    const wallScaleY = wallDimensions.height / baseWallSize.height;
    
    // Combine resolution and wall scaling for optimal results
    const finalScaleX = Math.sqrt(resolutionScaleX * wallScaleX);
    const finalScaleY = Math.sqrt(resolutionScaleY * wallScaleY);
    const avgScale = (finalScaleX + finalScaleY) / 2;
    
    // Clamp scale to reasonable bounds
    const clampedScale = Math.max(0.3, Math.min(3.0, avgScale));
    
    console.log(`Border scaling: DUI=${resolution.width}x${resolution.height}, Wall=${wallDimensions.length}x${wallDimensions.height}, Scale=${clampedScale.toFixed(2)}`);
    
    // Update CSS custom properties
    root.style.setProperty('--scale-factor', clampedScale);
    root.style.setProperty('--resolution-width', resolution.width);
    root.style.setProperty('--resolution-height', resolution.height);

    const locationName = document.querySelector('.location-name');
    const borderLines = document.querySelectorAll('.border-lines');
    const gridOverlay = document.querySelector('.grid-overlay');

    if (locationName) {
        // Much larger base font size, scaled by wall dimensions
        const baseFontSize = Math.max(
            resolution.width * 0.01,  // 8% of width
            resolution.height * 0.12  // 15% of height
        );

        // Scale based on wall dimensions - bigger walls get proportionally bigger text
        const dimensionScale = Math.min(wallDimensions.length / 20, wallDimensions.height / 5);
        const finalFontSize = Math.max(60, Math.min(400, baseFontSize * dimensionScale));

        locationName.style.fontSize = `${finalFontSize}px`;

        // Adjust letter spacing based on scale
        const letterSpacing = Math.max(0.05, Math.min(0.3, avgScale * 0.1));
        locationName.style.letterSpacing = `${letterSpacing}em`;

        // Ensure text fits within container
        const maxWidth = resolution.width * 0.9;
        locationName.style.maxWidth = `${maxWidth}px`;
    }

    // Scale border line width
    borderLines.forEach(line => {
        const scaledWidth = Math.max(2, 4 * avgScale);
        line.style.width = `${scaledWidth}px`;
    });

    // Scale grid overlay
    if (gridOverlay) {
        const scaledGridSize = Math.max(30, 80 * avgScale);
        gridOverlay.style.backgroundSize = `${scaledGridSize}px ${scaledGridSize}px`;
    }

    // Update CSS custom properties for responsive design
    root.style.setProperty('--scale-factor', avgScale);
    root.style.setProperty('--width-scale', widthScale);
    root.style.setProperty('--height-scale', heightScale);
}

// Initial setup
document.addEventListener('DOMContentLoaded', function () {
    console.log('Modern Augmented Border UI Loaded');
    // Hide by default until 'show' event is received
    document.body.style.display = 'none';

    // Mock for testing in browser.
    // This simulates receiving an event from the game.

});