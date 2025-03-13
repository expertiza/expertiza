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
            })
            .catch((error) => {
                console.error('There was a problem with the fetch operation:', error);
            });
    });
});
