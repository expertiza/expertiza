function formatDate(date) {
    var month = new Array()
    month[0] = 'Jan'
    month[1] = 'Feb'
    month[2] = 'Mar'
    month[3] = 'Apr'
    month[4] = 'May'
    month[5] = 'Jun'
    month[6] = 'Jul'
    month[7] = 'Aug'
    month[8] = 'Sep'
    month[9] = 'Oct'
    month[10] = 'Nov'
    month[11] = 'Dec'

    var hours = date.getHours()
    var minutes = date.getMinutes()
    var ampm = hours >= 12 ? 'PM' : 'AM'
    hours = hours % 12
    hours = hours ? hours : 12 // the hour '0' should be '12'
    minutes = minutes < 10 ? '0' + minutes : minutes
    var strTime = hours + ':' + minutes + ' ' + ampm
    return month[date.getMonth()] + ' ' + date.getDate() + ', ' + date.getFullYear() + ' - ' + strTime
}