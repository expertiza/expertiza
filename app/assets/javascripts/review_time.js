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
function endTime2(map_id, round, link) {
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