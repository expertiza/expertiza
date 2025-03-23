
document.addEventListener('DOMContentLoaded', function() {

    // Find all save buttons and add event listeners
    const saveButtons = document.querySelectorAll('[id^="save-meeting-date-"]');

    saveButtons.forEach(button => {
        button.addEventListener('click', function(event) {
            event.preventDefault(); // Prevent default link behavior

            const meetingIndex = button.dataset.meetingIndex;
            const meetingId = button.dataset.meetingId;
            const teamId = button.dataset.teamId;

            if(button.dataset.delete == 1){
                fetch(`/teams/${teamId}/meetings/${meetingId}`, { // Use the correct route for deleting a meeting
                    method: 'DELETE',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content') // Add CSRF token
                    }
                })
                    .then(response => {
                        if (!response.ok) {
                            throw new Error(`HTTP error! status: ${response.status}`);
                        }
                        // No need to parse JSON if the server returns a 204 No Content response,
                        // otherwise parse as needed
                        return response.text(); // or response.json() if your API returns json after deletion
                    })
                    .then(data => {
                        console.log('Meeting date deleted successfully:', data);
                        // Handle successful deletion (e.g., update the UI)
                        window.location.reload();
                    })
                    .catch(error => {
                        console.error('Error deleting meeting date:', error);
                        // Handle errors (e.g., display an error message to the user)
                    });
            }else {


                const dateInput = document.getElementById(`meeting-date-${meetingIndex}-${teamId}`);

                if (dateInput) {
                    const newDate = dateInput.value; // Get the date from the input

                    console.log(newDate);

                    if (!newDate) {
                        alert('Please select a meeting date.');
                        return;
                    }

                    // Send AJAX request to create a new meeting date
                    fetch(`/teams/${teamId}/meetings`, { // Use the correct route for creating a meeting
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content') // Add CSRF token
                        },
                        body: JSON.stringify({meeting: {meeting_date: newDate}}) // Send data in the expected format
                    })
                        .then(response => {
                            if (!response.ok) {
                                throw new Error(`HTTP error! status: ${response.status}`);
                            }
                            return response.json(); // Or response.text() if your server returns plain text
                        })
                        .then(data => {
                            console.log('Meeting date created successfully:', data);
                            // Handle successful creation (e.g., update the UI)
                            window.location.reload();
                        })
                        .catch(error => {
                            console.error('Error creating meeting date:', error);
                            // Handle errors (e.g., display an error message to the user)
                        });
                }
            }
        });
    });

});
