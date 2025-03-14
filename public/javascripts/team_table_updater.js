document.addEventListener('DOMContentLoaded', function () {
    const tableHeaders = document.querySelector('thead'); // Target only the <thead>
    const tableBody = document.getElementById('teams_table_body'); // Target only the <tbody>

    // Use a global variable to track the current number of columns
    if (!window.currColumnNum) {
        window.currColumnNum = 3; // Default to 3 if not already set
    }

    // Listen for clicks on "Add Meeting Column" buttons in the header
    tableHeaders.addEventListener('click', function (event) {
        if (event.target && event.target.closest('.add-meeting-col')) {
            event.preventDefault(); // Prevent default link behavior

            const button = event.target.closest('.add-meeting-col'); // The clicked button
            const teamType = button.dataset.teamType; // Get teamType from data attribute
            const id = button.dataset.id; // Get id from data attribute
            const currColumnNum = window.currColumnNum; // Get current column count

            console.log(id);
            console.log(teamType);

            const headerUrl = `/teams/increase_table_headers?type=${teamType}&id=${id}&colNum=${currColumnNum}`;
            const bodyUrl = `/teams/increase_table_columns?type=${teamType}&id=${id}&colNum=${currColumnNum}`;

            // Update headers and body together
            Promise.all([
                fetch(headerUrl, { headers: { 'X-Requested-With': 'XMLHttpRequest' } }),
                fetch(bodyUrl, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
            ])
                .then(async ([headerResponse, bodyResponse]) => {
                    if (!headerResponse.ok || !bodyResponse.ok) {
                        throw new Error('Network response was not ok');
                    }

                    const headerHtml = await headerResponse.text();
                    const bodyHtml = await bodyResponse.text();

                    //console.log(headerHtml);
                    //console.log(bodyHtml);
                    tableHeaders.innerHTML = headerHtml; // Update only the <thead> with new content
                    tableBody.innerHTML = bodyHtml; // Update only the <tbody> with new content

                    window.currColumnNum++; // Increment currColumnNum for subsequent clicks
                })
                .catch((error) => {
                    console.error('There was a problem with the fetch operation:', error);
                });
        }
    });
});
