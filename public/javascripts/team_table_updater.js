document.addEventListener('DOMContentLoaded', function () {
    const courseSelect = document.querySelector('.filter-dropdown');
    const tableBody = document.querySelector('tbody'); // Ensure this targets only the table body

    courseSelect.addEventListener('change', function () {
        const selectedId = courseSelect.value;

        console.log('Dropdown changed: ', selectedId); // Debugging dropdown value

        // Fetch new table data via AJAX
        const url = `/teams/list?type=${teamType}&id=${selectedId}`;
        fetch(url, {
            headers: { 'X-Requested-With': 'XMLHttpRequest' },
        })
            .then((response) => {
                if (!response.ok) {
                    throw new Error(`Network response was not ok: ${response.statusText}`);
                }
                return response.text();
            })
            .then((data) => {
                console.log('Response data: ', data); // Debugging response data

                // Clear the table body before appending new content
                tableBody.innerHTML = ''; // Clear all rows in the table body

                // If no data is returned, render an empty row
                if (data.trim() === '') {
                    tableBody.innerHTML = '<tr><td colspan="9" style="text-align: center;">No teams found.</td></tr>';
                } else {
                    // Replace only the table body content with returned rows (<tr>)
                   tableBody.innerHTML = data;
                }

                // Update the course header dynamically
                // Assuming you want to display the selected assignment's name
                // You might need to fetch this name via AJAX or include it in the response
                // For simplicity, let's assume you have a function to get the assignment name
                //const assignmentName =
                    updateHeader(teamType,selectedId); // Implement this function
                //courseHeader.innerHTML = `Teams for ${assignmentName}`;

            })
            .catch((error) => {
                console.error('There was a problem with the fetch operation:', error);
            });
    });

    // Example function to get the assignment name (you need to implement this)
    function updateHeader(teamType, assignmentId) {
        const url = `/teams/update_header?type=${teamType}&id=${assignmentId}`;
        fetch(url, {
            headers: { 'X-Requested-With': 'XMLHttpRequest' },
        })
            .then((response) => {
                if (!response.ok) {
                    throw new Error(`Network response was not ok: ${response.statusText}`);
                }
                return response.json();
            })
            .then((data) => {
                console.log('Response data: ', data); // Debugging response data
                const courseHeader = document.getElementById('course-header');
                courseHeader.innerHTML = data.header;
            })
            .catch((error) => {
                console.error('There was a problem with the fetch operation:', error);
            });
    }

});
