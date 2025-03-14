document.addEventListener('DOMContentLoaded', function () {
    const tableHeaders = document.querySelector('thead'); // Target only the <thead>

    // Use event delegation to listen for clicks on "Add Meeting Column" buttons in the header
    tableHeaders.addEventListener('click', function (event) {
        if (event.target && event.target.closest('.add-meeting-col')) {
            event.preventDefault(); // Prevent default link behavior

            const currColumnNum = parseInt(window.currColumnNum) || 3; // Use global variable or fallback to 3
            const url = `/teams/increase_table_headers?colNum=${currColumnNum}`;

            fetch(url, {
                headers: { 'X-Requested-With': 'XMLHttpRequest' }
            })
                .then((response) => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.text();
                })
                .then((html) => {
                    tableHeaders.innerHTML = html; // Update only the <thead> with new content
                    window.currColumnNum++; // Increment currColumnNum for subsequent clicks
                })
                .catch((error) => {
                    console.error('There was a problem with the fetch operation:', error);
                });
        }
    });
});
