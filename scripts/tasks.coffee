# Description:
#   Allows tasks (TODOs) to be added to Hubot
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   :task add <task> - Add a task
#   :task list tasks - List the tasks
#   :task delete <task number> - Delete a task
#
# Author:
#   Crofty

class Tasks
  constructor: (@robot) ->
    @cache = []
    @robot.brain.on 'loaded', =>
      if @robot.brain.data.tasks
        @cache = @robot.brain.data.tasks
  nextTaskNum: ->
    maxTaskNum = if @cache.length then Math.max.apply(Math,@cache.map (n) -> n.num) else 0
    maxTaskNum++
    maxTaskNum
  add: (taskString, room_name) ->
    task = {num: @nextTaskNum(), room: room_name, task: taskString}
    @cache.push task
    @robot.brain.data.tasks = @cache
    task
  all: -> @cache
  deleteByNumber: (num) ->
    index = @cache.map((n) -> n.num).indexOf(parseInt(num))
    task = @cache.splice(index, 1)[0]
    @robot.brain.data.tasks = @cache
    task

module.exports = (robot) ->
  tasks = new Tasks robot

  robot.hear /(:task add|:add task) (.+?)$/i, (msg) ->
    task = tasks.add msg.match[2], msg.message.room
    msg.send "Task added: ##{task.num} - #{task.task}"

  robot.hear /(:task list|:list tasks)/i, (msg) ->
    response = ""
    count = 0
    for task, num in tasks.all()
      if task.room == msg.message.room
        response += "##{task.num} - #{task.task}\n"
        count++
    if count > 0
      msg.send response
    else 
      msg.send "There are no tasks"

  robot.hear /(:task delete|:delete task) #?(\d+)/i, (msg) ->
    taskNum = msg.match[2]
    task = tasks.deleteByNumber taskNum
    msg.send "Task deleted: ##{task.num} - #{task.task}"
