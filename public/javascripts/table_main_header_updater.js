function updateHeader(courseId, assignmentId) {
    const url = `/teams/update_header?course_id=${courseId}&assignment_id=${assignmentId}`;
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
            const courseHeader = document.getElementById('course-header');
            courseHeader.innerHTML = data.header;
        })
        .catch((error) => {
            console.error('There was a problem with the fetch operation:', error);
        });
}
