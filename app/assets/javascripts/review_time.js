/**
 * Signal the submission viewing even controller to start timing
 * for a particular review asset.
 *
 * @param map_id The ID of the review map from Expertiza
 * @param round The Review Round e.g. 1, 2, etc
 * @param link The asset being review.
 */
function startTime(map_id, round, link) {
    $.ajax({
        type: "POST",
        url: '/submission_viewing_events/start_timing',
        data: $.param({
            submission_viewing_event: {
                map_id: map_id,
                round: round,
                link: link
            }
        }),
        error: function (e) {
            console.log(e);
        },
        dataType: "json"
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
    var data = {
        submission_viewing_event: {
            map_id: map_id,
            round: round
        }
    };

    if (link) {
        data.submission_viewing_event.link = link;
    }

    $.ajax({
        type: 'POST',
        dataType: 'json',
        async: false,
        url: '/submission_viewing_events/end_timing',
        data: $.param(data),
        error: function (e) {
            console.log(e);
        }
    });
}

/**
 * Signal the submission viewing event controller to
 * stop timing for all open review assets for [round].
 *
 * @param map_id The ID of the review map from Expertiza
 * @param round The Review Round e.g. 1, 2, etc
 */
function endRound(map_id, round) {
    $.ajax({
        type: 'POST',
        dataType: 'json',
        async: false,
        url: '/submission_viewing_events/end_timing',
        data: $.param({
            submission_viewing_event: {
                map_id: map_id,
                round: round
            }
        }),
        error: function (e) {
            console.log(e);
        }
    });
}

/**
 * Signal the submission viewing event controller to stop
 * timing for all review assets for [round] and persist
 * their timing data.
 *
 * @param map_id The ID of the review map from Expertiza
 * @param round The Review Round e.g. 1, 2, etc
 */
function endRoundAndSave(map_id, round) {
    $.ajax({
        type: 'POST',
        dataType: 'json',
        async: false,
        url: '/submission_viewing_events/end_round_and_save',
        data: $.param({
            submission_viewing_event: {
                map_id: map_id,
                round: round
            }
        }),
        error: function (e) {
            console.log(e);
        }
    });
}

/**
 * Signal the submission viewing event controller to
 * stop and restart timing for all review assets for [round].
 *
 * @param map_id The ID of the review map from Expertiza
 * @param round The Review Round e.g. 1, 2, etc
 */
function resetRound(map_id, round) {
    $.ajax({
        type: 'POST',
        dataType: 'json',
        async: false,
        url: '/submission_viewing_events/reset_timing',
        data: $.param({
            submission_viewing_event: {
                map_id: map_id,
                round: round
            }
        }),
        error: function (e) {
            console.log(e);
        },
    });
}

/**
 * Signal the submission viewing event controller to persist
 * timing for all review assets to the database.
 * @param map_id The ID of the review map from Expertiza
 * @param round The Review Round e.g. 1, 2, etc
 */
function saveAll(map_id, round) {
    $.ajax({
        type: 'POST',
        dataType: 'json',
        async: false,
        url: '/submission_viewing_events/hard_save',
        data: $.param({
            submission_viewing_event: {
                map_id: map_id,
                round: round
            }
        }),
        error: function (e) {
            console.log(e);
        }
    });
}