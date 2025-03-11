// table_updater.js (modified)
document.addEventListener('DOMContentLoaded', function () {
    const courseSelect = document.querySelector('.filter-dropdown');
    const headerElement = document.querySelector('#course-header');
    const tableBody = document.querySelector('tbody'); // Ensure this targets only the table body

    courseSelect.addEventListener('change', function () {
        const selectedId = courseSelect.value;
        const selectedName = courseSelect.options[courseSelect.selectedIndex].text;

        // Update the header with the selected name
        headerElement.textContent = `Teams for ${selectedName}`;

        // Fetch new table data via AJAX
        const url = `/teams/list?type=${teamType}&id=${selectedId}`;
        fetch(url, {
            headers: { 'X-Requested-With': 'XMLHttpRequest' },
        })
            .then((response) => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.text();
            })
            .then((data) => {
                // Replace only the table body content with returned rows (<tr>)
                tableBody.innerHTML = data;
            })
            .catch((error) => {
                console.error('There was a problem with the fetch operation:', error);
            });
    });
});
