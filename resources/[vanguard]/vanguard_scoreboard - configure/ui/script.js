// Scoreboard Management System
class ScoreboardManager {
    constructor() {
        this.isVisible = false;
        this.players = [];
        this.jobStats = [];
        this.maxPlayers = 32;
        this.currentPlayers = 0;
        this.config = {};
        this.locales = {};
        this.isClosing = false;
        this.lastDataHash = '';
        
        this.init();
    }

    init() {
        this.bindEvents();
        this.requestConfig();
    }

    bindEvents() {
        // Removido o event listener para ESC - agora só F10 controla

        // Listen for NUI messages
        window.addEventListener('message', (event) => {
            const data = event.data;
            switch (data.action) {
                case 'show':
                    this.show(data.config, data.locales);
                    break;
                case 'hide':
                    this.hide();
                    break;
                case 'updateData':
                    this.updateData(data.data);
                    break;
                case 'setConfig':
                    this.setConfig(data.config, data.locales);
                    break;
            }
        });

        // Prevent context menu
        document.addEventListener('contextmenu', (e) => {
            if (this.isVisible) e.preventDefault();
        });

        // Prevent text selection or drag while scoreboard is visible
        document.addEventListener('selectstart', (e) => {
            if (this.isVisible) e.preventDefault();
        });
        document.addEventListener('dragstart', (e) => {
            if (this.isVisible) e.preventDefault();
        });
    }

    setConfig(config, locales) {
        this.config = config || {};
        this.locales = locales || {};
        this.updateTexts();
    }

    updateTexts() {
        const titleElement = document.querySelector('.main-title');
        const subtitleElement = document.querySelector('.sub-title');
        const playersOnlineLabel = document.querySelector('.counter-label');

        if (titleElement && this.config.scoreboardTitle) titleElement.textContent = this.config.scoreboardTitle;
        if (subtitleElement && this.config.scoreboardSubtitle) subtitleElement.textContent = this.config.scoreboardSubtitle;
        if (playersOnlineLabel && this.locales.players_online) playersOnlineLabel.textContent = this.locales.players_online;

        // Update header labels
        const headerItems = document.querySelectorAll('.header-item span');
        if (headerItems.length >= 4) {
            if (this.locales.player_name) headerItems[0].textContent = this.locales.player_name;
            if (this.locales.job) headerItems[1].textContent = this.locales.job;
            if (this.locales.rank) headerItems[2].textContent = this.locales.rank;
            if (this.locales.ping) headerItems[3].textContent = this.locales.ping;
        }
    }

    requestConfig() {
        this.postNUI('requestConfig');
    }

    show(config, locales) {
        if (this.isVisible || this.isClosing) return;

        this.isVisible = true;
        this.isClosing = false;

        if (config) this.config = config;
        if (locales) this.locales = locales;

        const container = document.getElementById('scoreboard');
        if (!container) return;

        container.className = `scoreboard-container ${this.config.scoreboardType || 'fullscreen'}`;
        container.classList.remove('hidden', 'closing');

        this.updateTexts();
    }

    hide() {
        if (!this.isVisible || this.isClosing) return;

        this.isClosing = true;
        const container = document.getElementById('scoreboard');
        if (!container) return;

        container.classList.add('closing');

        setTimeout(() => {
            this.isVisible = false;
            this.isClosing = false;
            container.classList.add('hidden');
            container.classList.remove('closing');
            this.lastDataHash = '';
        }, 300);
    }

    updateData(data) {
        if (!data) return;

        const dataHash = JSON.stringify(data);
        if (dataHash === this.lastDataHash) return;
        this.lastDataHash = dataHash;

        if (data.players) {
            this.players = data.players;
            this.renderPlayers();
        }

        if (data.jobStats) {
            this.jobStats = data.jobStats;
            this.renderJobStats();
        }

        if (data.serverInfo) {
            this.currentPlayers = data.serverInfo.currentPlayers;
            this.maxPlayers = data.serverInfo.maxPlayers;
            this.updatePlayerCount();
        }
    }

    renderJobStats() {
        const container = document.getElementById('job-stats');
        if (!container) return;

        container.innerHTML = '';
        this.jobStats.forEach((job, index) => {
            const jobCard = document.createElement('div');
            jobCard.className = 'job-stat-card';
            
            const secondaryColor = this.safeAdjustColorBrightness(job.color, -20);
            jobCard.style.setProperty('--job-color', job.color);
            jobCard.style.setProperty('--job-color-secondary', secondaryColor);
            jobCard.style.setProperty('--job-glow', job.color + '50');
            jobCard.style.setProperty('--delay', `${index * 100}ms`);

            jobCard.innerHTML = `
                <div class="job-stat-content">
                    <div class="job-stat-inner">
                        <div class="job-icon-container">
                            <i class="${job.icon}" style="color: ${job.iconColor || '#fff'}"></i>
                        </div>
                        <div class="job-info">
                            <h3>${job.label}</h3>
                            <div class="job-count">${job.count}</div>
                        </div>
                    </div>
                </div>
            `;

            container.appendChild(jobCard);
        });
    }

    renderPlayers() {
        const container = document.getElementById('player-list');
        if (!container) return;

        container.innerHTML = '';
        this.players.forEach((player, index) => {
            const playerRow = document.createElement('div');
            playerRow.className = `player-row ${player.type || 'player'}`;
            playerRow.style.setProperty('--delay', `${index * 50}ms`);

            const pingClass = this.getPingClass(player.ping);
            const pingBars = this.generatePingBars(player.ping);

            playerRow.innerHTML = `
                <div class="player-name">
                    ${player.icon ? `<i class="${player.icon} player-icon"></i>` : ''}
                    <span>${player.name}${this.config.showPlayerIds ? ` (${player.id})` : ''}</span>
                </div>
                <div class="player-job">${player.job || 'N/A'}</div>
                <div class="player-rank">${player.rank || 'N/A'}</div>
                <div class="ping-container">
                    ${this.config.showPlayerPing !== false ? `
                        <div class="ping-bars ${pingClass}">
                            ${pingBars}
                        </div>
                        <span class="ping-value">${player.ping}ms</span>
                    ` : ''}
                </div>
            `;
            container.appendChild(playerRow);
        });
    }

    generatePingBars(ping) {
        const activeBars = this.getPingBars(ping);
        let barsHTML = '';
        for (let i = 1; i <= 4; i++) {
            barsHTML += `<div class="ping-bar ${i <= activeBars ? 'active' : ''}"></div>`;
        }
        return barsHTML;
    }

    getPingBars(ping) {
        if (ping <= 50) return 4;
        if (ping <= 100) return 3;
        if (ping <= 150) return 2;
        return 1;
    }

    getPingClass(ping) {
        if (ping <= 50) return 'ping-good';
        if (ping <= 100) return 'ping-medium';
        return 'ping-bad';
    }

    updatePlayerCount() {
        const currentElement = document.getElementById('current-players');
        const maxElement = document.getElementById('max-players');
        if (currentElement) currentElement.textContent = this.currentPlayers;
        if (maxElement) maxElement.textContent = this.maxPlayers;
    }

    safeAdjustColorBrightness(color, amount) {
        if (!color || typeof color !== 'string') return color || '#000000';
        const hex = color.replace('#', '');
        if (!/^[0-9A-Fa-f]{6}$/.test(hex)) return color;
        try {
            const r = parseInt(hex.substring(0, 2), 16);
            const g = parseInt(hex.substring(2, 4), 16);
            const b = parseInt(hex.substring(4, 6), 16);
            const newR = Math.max(0, Math.min(255, r + amount));
            const newG = Math.max(0, Math.min(255, g + amount));
            const newB = Math.max(0, Math.min(255, b + amount));
            return '#' + ((newR << 16) | (newG << 8) | newB).toString(16).padStart(6, '0');
        } catch {
            return color;
        }
    }

    postNUI(action, data = {}) {
        if (typeof fetch === 'undefined') return;
        const resourceName = this.getResourceName();
        if (!resourceName) return;
        fetch(`https://${resourceName}/${action}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        }).catch(() => {});
    }

    getResourceName() {
        if (window.GetParentResourceName) return window.GetParentResourceName();
        return 'vanguard_scoreboard';
    }
}

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    window.scoreboardManager = new ScoreboardManager();
});

// Global function for FiveM
function GetParentResourceName() {
    return window.scoreboardManager ? window.scoreboardManager.getResourceName() : 'vanguard_scoreboard';
}

// Global error catcher
window.addEventListener('error', (e) => {
    console.warn('Scoreboard error caught:', e.message);
    return true;
});