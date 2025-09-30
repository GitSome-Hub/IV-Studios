function closeJobCenter() {
    fetch('https://fs-jobcenter/close', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });

    // Hide the job center menu
    document.getElementById('job-center').style.display = 'none';
}

function selectJob(job) {
    fetch('https://fs-jobcenter/selectJob', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ job: job })
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === 'open') {
        document.getElementById('job-center').style.display = 'block';

        // Populate the job list dynamically
        const jobListContainer = document.getElementById('job-list');
        jobListContainer.innerHTML = ''; // Clear existing content
        data.jobs.forEach(job => {
            const jobBox = document.createElement('div');
            jobBox.className = 'job-box';

            // Create the image element
            const jobImage = document.createElement('img');
            jobImage.src = job.image;
            jobImage.alt = job.label;

            // Create job info container
            const jobInfo = document.createElement('div');
            jobInfo.className = 'job-info';

            // Job title
            const jobTitle = document.createElement('div');
            jobTitle.className = 'job-title';
            jobTitle.textContent = job.label;

            // Select button
            const selectButton = document.createElement('button');
            selectButton.className = 'select-btn';
            selectButton.textContent = "SIGN DOCUMENTS";
            selectButton.onclick = function() { selectJob(job.name); };

            // Append elements to job box
            jobInfo.appendChild(jobTitle);
            jobInfo.appendChild(selectButton);
            jobBox.appendChild(jobImage);
            jobBox.appendChild(jobInfo);
            jobListContainer.appendChild(jobBox);
        });

    } else if (data.action === 'close') {
        document.getElementById('job-center').style.display = 'none';
    }
});

// Add event listener to close the menu with the Esc key
window.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') { // Check if the Esc key is pressed
        closeJobCenter();
    }
});
