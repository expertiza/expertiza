//This file will need to change to implement the save function for the meeting
document.addEventListener('turbolinks:load', function() {
    // Find all save buttons and add event listeners
    const saveButtons = document.querySelectorAll('[id^="save-meeting-date-"]');
    saveButtons.forEach(button => {
        button.addEventListener('click', function(event) {
            event.preventDefault(); // Prevent default link behavior

            const meetingIndex = button.id.split('-')[2];
            const teamId = button.id.split('-')[3];
            const dateSpan = document.getElementById(`meeting-date-${meetingIndex}-${teamId}`);

            const newDate = dateSpan.textContent;

            // Send AJAX request to update the meeting date
            //this URL will need to change for the actual save function
            fetch(`/teams/${teamId}/update_meeting_date`, {
                method: 'PATCH',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ meeting_index: meetingIndex, new_date: newDate }),
            })
                .then(response => response.text())
                .then(data => {
                    console.log('Meeting date updated successfully');
                })
                .catch(error => console.error('Error updating meeting date:', error));
        });
    });
});
