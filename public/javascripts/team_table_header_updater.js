document.addEventListener('DOMContentLoaded', function () {
    const courseSelect = document.querySelector('.filter-dropdown');
    const tableHeaders = document.querySelector('thead'); // Target only thead

    courseSelect.addEventListener('change', function () {
        const selectedId = courseSelect.value;

        // Fetch new table headers via AJAX
        const url = `/teams/list/headers?type=${teamType}&id=${selectedId}`;
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
                // Update headers directly
                tableHeaders.innerHTML = data;
            })
            .catch((error) => {
                console.error('There was a problem with the fetch operation:', error);
            });
    });
});
