# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# the compiled file.
#
# WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
# GO AFTER THE REQUIRES BELOW.
#
#= require jquery
#= require jquery_ujs
#= require twitter/bootstrap
#= require_tree .

$.canEdit = () ->
    $("#can_edit").val() == "true"

$.fn.gain = (message) ->
    $gain = $ "<div class='gain'>
          <h1>#{message}</h1>
        </div>"
    location = @.offset()
    $gain.css
        position: "fixed"
        "z-index": 1000
        left: location.left
        top: location.top
        color: "#468847"
    $("body").append $gain
    $gain.animate(
            opacity: 0
            top: location.top - 42
        1000
        -> $gain.remove())

$.standardChecks = (server_result) ->
    $.checkLevel server_result
    $.checkXp server_result

$.checkLevel = (server_result) ->
    if server_result.new_level_label?
        $(".character-level").text server_result.new_level_label
    if server_result.levels_gained?
        if server_result.levels_gained == 1
            $(".character-level").gain "+#{server_result.levels_gained}&nbsp;level"
        else if server_result.levels_gained > 1
            $(".character-level").gain "+#{server_result.levels_gained}&nbsp;levels"

$.checkXp = (server_result) ->
    if server_result.new_xp_total?
        $(".character-xp").text "#{server_result.new_xp_total} xp"
    if server_result.xp_gained? && server_result.xp_gained > 0
        $(".character-xp").gain "+#{server_result.xp_gained}&nbsp;xp"

$.checkGoal = (server_result, goal_id) ->
    if server_result.goal_completed_percent?
        new_width = $(".goal-#{goal_id}-progress").width() * (server_result.goal_completed_percent / 100.0)
        $(".goal-#{goal_id}-progress .bar").stop().animate width: new_width

        if server_result.goal_completed_percent == 100
            $(".goal-#{goal_id} .goal-label").addClass("text-success")
        else
            $(".goal-#{goal_id} .goal-label").removeClass("text-success")

$.showError = (message) ->
    $modal = $ "<div class='modal hide fade'>
          <div class='modal-header'>
            <button type='button' class='close' data-dismiss='modal' aria-hidden='true'>&times;</button>
            <h3>An Error Occurred</h3>
          </div>
          <div class='modal-body'>
            <p>#{message}</p>
          </div>
          <div class='modal-footer'>
            <button data-dismiss='modal' class='btn' aria-hidden='true'>Dismiss</button>
          </div>
        </div>"
    $("body").append $modal
    $modal.on "hidden", ->
        $modal.remove()
    $modal.modal()

$.createForm = (method, content) ->
    $form = $ "<form class='tome-edit-form' style='display: none;'>
          <input type='hidden' name='_method' value='#{method}' />
          <input type='hidden' name='authenticity_token' />
          #{content}
        </form>"
    $form.find("input[name='authenticity_token']").val $("meta[name='csrf-token']").attr("content")
    $form

$.setupEdits = () ->
    $(".tome-item").click ->
        wasClicked = $(@).is ".tome-item-clicked"
        $(".tome-item-clicked").removeClass "tome-item-clicked"
        $(@).addClass "tome-item-clicked" unless wasClicked
    $(".edit-tome-item").each ->
        target = $(@).data "for"
        $target = $ "##{target}-value"
        placeholder = $target.data "input-placeholder"
        $form = $.createForm "PUT", "
            <input type='hidden' name='attribute' value='#{target}' />
            <input type='text' name='value' placeholder='#{placeholder}' />"
        $input = $form.find "input[name='value']"
        $form.submit ->
            $.ajax $("#edit_tome_path").val(),
                type: "POST"
                data: $(@).serialize()
                success: (result) ->
                    if result.new_value?.length
                        $target.text result.new_value
                        $target.attr "data-original-value", result.new_value
                    else
                        $target.text placeholder
                        $target.attr "data-original-value", ""
                    $form.hide()
                    $target.show()
                    $.standardChecks result
                error: ->
                    $form.hide()
                    $target.show()
                    $.showError "Drat, something went wrong!"
            false
        $target.after $form
        $(@).click ->
            $target.hide()
            $input.val $target.attr("data-original-value")
            $form.show()
            $input.focus()
            false

$.setupNewGoal = () ->
    $(".create-goal").each ->
        $form = $.createForm "POST", "
            <input type='text' name='label' placeholder='a long-term goal' />"
        $form.after "<br />"
        $input = $form.find "input[name='label']"
        $form.submit ->
            $.ajax $("#create_goal_path").val(),
                type: "POST"
                data: $(@).serialize()
                success: (result) ->
                    $form.hide()
                    $.standardChecks result
                    $("#new-goals").append result.html if result.html?
                error: ->
                    $form.hide()
                    $.showError "Drat, something went wrong!"
            false
        $(@).before $form
        $(@).click ->
            $input.val ""
            $form.show()
            $input.focus()
            false

$.setupGoals = () ->
    $(document).on "hide", ".tasks", ->
        $("#toggle-#{$(@).attr "id"}").find("i").removeClass("icon-chevron-up").addClass("icon-chevron-down")
    $(document).on "show", ".tasks", ->
        $("#toggle-#{$(@).attr "id"}").find("i").removeClass("icon-chevron-down").addClass("icon-chevron-up")

$.setupNewTask = () ->
    $(document).on "click", ".create-task", ->
        goal_id = $(@).data "goal-id"
        new_task_path = $(@).data "new-task-path"
        $form = $.createForm "POST", "
            <input type='text' name='label' placeholder='a task towards this goal' />"
        $br = $ "<br />"
        $form.after $br
        $input = $form.find "input[name='label']"
        $form.submit ->
            $.ajax new_task_path,
                type: "POST"
                data: $(@).serialize()
                success: (result) ->
                    $form.remove()
                    $br.remove()
                    $.standardChecks result
                    $.checkGoal result, goal_id
                    $("#new-tasks-for-#{goal_id}").append result.html if result.html?
                error: ->
                    $form.remove()
                    $br.remove()
                    $.showError "Drat, something went wrong!"
            false
        $(@).before $form
        $form.show()
        $input.focus()
        false

$.setupToggleTasks = () ->
    $(document).on "click", ".toggle-task", ->
        goal_id = $(@).data "goal-id"
        task_id = $(@).data "task-id"
        $form = $.createForm "PUT", "
            <input type='hidden' name='toggle' value='true' />"
        $(@).before $form
        $.ajax $(@).data("toggle-task-path"),
            type: "POST"
            data: $form.serialize()
            success: (result) ->
                $form.remove()
                $.standardChecks result
                $.checkGoal result, goal_id

                if result.task_completed_status == "completed"
                    $(".task-#{task_id}").removeClass("not_completed").addClass("completed")
                    $(".task-#{task_id}-btn").addClass("btn-success")
                else if result.task_completed_status == "not_completed"
                    $(".task-#{task_id}").removeClass("completed").addClass("not_completed")
                    $(".task-#{task_id}-btn").removeClass("btn-success")
            error: ->
                $form.remove()
                $.showError "Drat, something went wrong!"
        false

$ ->
    if $.canEdit()
        $.setupEdits()
        $.setupNewGoal()
        $.setupGoals()
        $.setupNewTask()
        $.setupToggleTasks()
