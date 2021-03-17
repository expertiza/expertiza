/**
 * Signal the submission viewing even controller to start timing
 * for a particular review asset.
 * @param map_id The ID of the review map from Expertiza
 * @param round The Review Round e.g. 1, 2, etc
 * @param link The asset being review.
 */
function startTime(map_id, round, link) {
    $.ajax({
        type: "POST",
        url: '/submission_viewing_events/record_start_time',
        data: $.param({
            submission_viewing_event: {
                map_id: map_id,
                round: round,
                link: link,
                start_at: Date.now()
            }
        })
    });
}

/**
 * Signal the submission viewing even controller to stop timing
 * for a particular review asset.
 * @param map_id The ID of the review map from Expertiza
 * @param round The Review Round e.g. 1, 2, etc
 * @param link The asset being review.
 */
function endTime(map_id, round, link) {
    $.ajax({
        type: 'POST',
        dataType: 'json',
        async: false,
        url: '/submission_viewing_events/record_end_time',
        data: $.param({
            submission_viewing_event: {
                map_id: map_id,
                round: round,
                link: link,
                end_at: Date.now()
            }
        })
    });
}

/**
 * Signal the submission viewing event controller to stop
 * timing for all open review assets.
 * @param map_id The ID of the review map from Expertiza
 * @param round The Review Round e.g. 1, 2, etc
 */
function markEndTime(map_id, round) {
    $.ajax({
        type: 'POST',
        dataType: 'json',
        async: false,
        url: '/submission_viewing_events/mark_end_time',
        data: $.param({
            submission_viewing_event: {
                map_id: map_id,
                round: round,
                end_at: Date.now()
            }
        })
    });
}

/**
 * Signal the submission viewing even controller to start timing
 * for a particular review asset.
 * @param map_id The ID of the review map from Expertiza
 * @param round The Review Round e.g. 1, 2, etc
 * @param link The asset being review.
 */
function startTime2(map_id, round, link) {
    $.ajax({
        type: "POST",
        url: '/submission_viewing_events/record_start_time2',
        data: JSON.stringify({
            map_id: map_id,
            round: round,
            link: link
        }),
        error: function(e) {
            console.log(e);
        },
        dataType: "json",
        contentType: "application/json"
    });
}

/**
 * Signal the submission viewing even controller to stop timing
 * for a particular review asset.
 * @param map_id The ID of the review map from Expertiza
 * @param round The Review Round e.g. 1, 2, etc
 * @param link The asset being review.
 */
function endTime2(map_id, round, link) {
    var data = {
        map_id: map_id,
        round: round
    };

    if (link) {
        data.link = link;
    }

    $.ajax({
        type: 'POST',
        dataType: 'json',
        async: false,
        url: '/submission_viewing_events/record_end_time',
        data: JSON.stringify(data),
        error: function(e) {
            console.log(e);
        },
        contentType: "application/json"
    });
}

/**
 * Signal the submission viewing event controller to stop
 * timing for all open review assets.
 * @param map_id The ID of the review map from Expertiza
 * @param round The Review Round e.g. 1, 2, etc
 */
function saveAll(map_id, round) {
    $.ajax({
        type: 'POST',
        dataType: 'json',
        async: false,
        url: '/submission_viewing_events/hard_save',
        data: JSON.stringify({
            map_id: map_id,
            round: round
        }),
        error: function(e) {
            console.log(e);
        },
        contentType: "application/json"
    });
}

function endRound(map_id, round) {
    $.ajax({
        type: 'POST',
        dataType: 'json',
        async: false,
        url: '/submission_viewing_events/end_timing',
        data: JSON.stringify({
            map_id: map_id,
            round: round
        }),
        error: function(e) {
            console.log(e);
        },
        contentType: "application/json"
    });
}

function saveAndEndRound(map_id, round) {
    $.ajax({
        type: 'POST',
        dataType: 'json',
        async: false,
        url: '/submission_viewing_events/end_round_and_save',
        data: JSON.stringify({
            map_id: map_id,
            round: round
        }),
        error: function(e) {
            console.log(e);
        },
        contentType: "application/json"
    });
}

function resetRound(map_id, round) {
    $.ajax({
        type: 'POST',
        dataType: 'json',
        async: false,
        url: '/submission_viewing_events/reset_timing',
        data: JSON.stringify({
            map_id: map_id,
            round: round
        }),
        error: function(e) {
            console.log(e);
        },
        contentType: "application/json"
    });
}