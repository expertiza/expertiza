document.addEventListener('DOMContentLoaded', function () {
    const tableBody = document.getElementById('teams_table_body');

    // Use event delegation: Attach a single click listener to the table body
    tableBody.addEventListener('click', function (event) {
        // Check if the clicked element is an "Add Meeting Column" button
        if (event.target && event.target.closest('.add-meeting-col')) {
            event.preventDefault(); // Prevent default link behavior

            const button = event.target.closest('.add-meeting-col'); // The clicked button
            const teamType = button.dataset.teamType; // Get teamType from data attribute
            const id = button.dataset.id; // Get id from data attribute
            const currColumnNum = parseInt(window.currColumnNum) || 3; // Use global variable or fallback to 3

            const url = `/teams/increase_table_columns?type=${teamType}&id=${id}&colNum=${currColumnNum}`;

            fetch(url, {
                headers: { 'X-Requested-With': 'XMLHttpRequest' }
            })
                .then(response => response.text())
                .then(html => {
                    tableBody.innerHTML = html;

                    // Increment currColumnNum for subsequent clicks
                    window.currColumnNum++;
                })
                .catch(error => console.error('Error:', error));
        }
    });
});
