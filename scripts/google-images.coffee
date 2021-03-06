# Description:
#   A way to interact with the Google Images API.
#
# Commands:
#   :image <query> - The Original. Queries Google Images for <query> and returns a random top result.
#   :gif <query> - The same thing as `image me`, except adds a few parameters to try to return an animated GIF instead.
#   :mustache <url> - Adds a mustache to the specified URL.
#   :mustache <query> - Searches Google Images for the specified query and mustaches it.

module.exports = (robot) ->
  robot.hear /:(image|img) (.*)/i, (msg) ->
    imageMe msg, msg.match[2], (url) ->
      msg.send url

  robot.hear /:gif (.*)/i, (msg) ->
    imageMe msg, msg.match[1], true, (url) ->
      msg.send url

  robot.hear /:(?:mo?u)?sta(?:s|c)he? (.*)/i, (msg) ->
    type = Math.floor(Math.random() * 3)
    mustachify = "http://mustachify.me/#{type}?src="
    imagery = msg.match[1]

    if imagery.match /^https?:\/\//i
      msg.send "#{mustachify}#{imagery}"
    else
      imageMe msg, imagery, false, true, (url) ->
        msg.send "#{mustachify}#{url}"

imageMe = (msg, query, animated, faces, cb) ->
  cb = animated if typeof animated == 'function'
  cb = faces if typeof faces == 'function'
  q = v: '1.0', rsz: '8', q: query, safe: 'active'
  q.imgtype = 'animated' if typeof animated is 'boolean' and animated is true
  q.imgtype = 'face' if typeof faces is 'boolean' and faces is true
  msg.http('http://ajax.googleapis.com/ajax/services/search/images')
    .query(q)
    .get() (err, res, body) ->
      images = JSON.parse(body)
      images = images.responseData?.results
      if images?.length > 0
        image  = msg.random images
        cb "#{image.unescapedUrl}#.png"

