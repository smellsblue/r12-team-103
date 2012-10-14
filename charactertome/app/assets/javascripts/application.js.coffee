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

$.rumble = () ->
    $("#rumble-target").append "
        <a href='http://railsrumble.com/?view=#{document.location}'>Vote for us</a>\nin the <a href='http://railsrumble.com'>2012 Rails Rumble</a>!"

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
    $.checkAlignment server_result
    $.checkGoal server_result
    $.checkTask server_result
    $.checkWeapon server_result

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

$.checkAlignment = (server_result) ->
    if server_result.new_morality?
        $("#character-morality-label").text server_result.new_morality
    if server_result.new_ethics?
        $("#character-ethics-label").text server_result.new_ethics

$.checkGoal = (server_result) ->
    if server_result.goal_completed_percent? && server_result.goal_id?
        new_width = $(".goal-#{server_result.goal_id}-progress").width() * (server_result.goal_completed_percent / 100.0)
        $(".goal-#{server_result.goal_id}-progress .bar").stop().animate width: new_width

        if server_result.goal_completed_percent == 100
            $(".goal-#{server_result.goal_id} .goal-label").addClass("text-success")
        else
            $(".goal-#{server_result.goal_id} .goal-label").removeClass("text-success")

    if server_result.html? && server_result.goal_id_for_new_task?
        $("#new-tasks-for-#{server_result.goal_id_for_new_task}").append server_result.html

    if server_result.new_goal_html?
        $("#new-goals").append server_result.new_goal_html

$.checkTask = (server_result) ->
    if server_result.task_completed_status == "completed" && server_result.completed_task_id?
        $(".task-#{server_result.completed_task_id}").removeClass("not_completed").addClass("completed")
        $(".task-#{server_result.completed_task_id}-btn").addClass("btn-success")
    else if server_result.task_completed_status == "not_completed"
        $(".task-#{server_result.completed_task_id}").removeClass("completed").addClass("not_completed")
        $(".task-#{server_result.completed_task_id}-btn").removeClass("btn-success")

$.checkWeapon = (server_result) ->
    if server_result.new_weapon_html?
        $("#new-weapons").append server_result.new_weapon_html

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

$.createForm = (method, content, cancelCallback) ->
    $form = $ "<form class='inline-form' style='display: none;'>
          <input type='hidden' name='_method' value='#{method}' />
          <input type='hidden' name='authenticity_token' />
          #{content}
          <button type='submit' class='btn btn-mini submit-button'>
            <i class='icon-ok'></i>
          </button>
          <button class='btn btn-mini cancel-button'>
            <i class='icon-remove'></i>
          </button>
        </form>"
    $form.find("input[name='authenticity_token']").val $("meta[name='csrf-token']").attr("content")
    $form.find(".cancel-button").click ->
        cancelCallback?()
        false
    $form

$.setupEdits = () ->
    $(document).on "click", ".tome-item", ->
        wasClicked = $(@).is ".tome-item-clicked"
        $(".tome-item-clicked").removeClass "tome-item-clicked"
        $(@).addClass "tome-item-clicked" unless wasClicked
    $(document).on "click", ".edit-tome-item", ->
        target = $(@).data "for"
        $target = $ "##{target}-value"
        return false if $target.data("editing") == "true"
        $target.data "editing", "true"
        placeholder = $target.data "input-placeholder"
        field = $target.data "edit-field"
        field = target unless field?
        $target.hide()
        $form = $.createForm "PUT", "
            <input type='hidden' name='attribute' value='#{field}' />
            <input type='text' name='value' placeholder='#{placeholder}' />", ->
            $target.removeData "editing"
            $form.remove()
            $target.show()
        $input = $form.find "input[name='value']"
        $input.val $target.attr("data-original-value")
        path = $target.data "edit-path"
        path = $("#edit_tome_path").val() unless path?
        $form.submit ->
            $.ajax path,
                type: "POST"
                data: $(@).serialize()
                success: (result) ->
                    $target.removeData "editing"
                    if result.new_value?.length
                        $target.text result.new_value
                        $target.attr "data-original-value", result.new_value
                    else
                        $target.text placeholder
                        $target.attr "data-original-value", ""
                    $form.remove()
                    $target.show()
                    $.standardChecks result
                error: ->
                    $target.removeData "editing"
                    $form.remove()
                    $target.show()
                    $.showError "Drat, something went wrong!"
            false
        $target.after $form
        $form.show()
        $input.focus()
        false

$.setupBarControls = () ->
    $(document).on "click", ".bar-control", ->
        target = $(@).data "for"
        $target = $ "##{target}-value"
        $form = $.createForm "PUT", "
            <input type='hidden' name='bar_attribute' value='#{target}' />
            <input type='hidden' name='adjustment' value='#{$(@).data "control-type"}' />"
        $target.after $form
        $.ajax $("#edit_tome_path").val(),
            type: "POST"
            data: $form.serialize()
            success: (result) ->
                if result.new_value?
                    new_width = $target.parents(".progress:first").width() * (result.new_value / 100.0)
                    $target.stop().animate width: new_width, 100
                $form.remove()
                $.standardChecks result
            error: ->
                $form.remove()
                $.showError "Drat, something went wrong!"
        false

$.setupDeletes = () ->
    $(document).on "click", ".delete-tome-item", ->
        target = $(@).data "for"
        $target = $ "##{target}"

        if $target.is(".goal") && $target.find(".not_completed").size() > 0
            $.showError "You must finish or delete all uncompleted tasks first!"
            return false

        $modal = $ "<div class='modal hide fade'>
              <div class='modal-header'>
                <button type='button' class='close' data-dismiss='modal' aria-hidden='true'>&times;</button>
                <h3>Are You Sure?</h3>
              </div>
              <div class='modal-body'>
                <p>Are you sure you want to delete that?</p>
              </div>
              <div class='modal-footer'>
                <button data-dismiss='modal' class='btn' aria-hidden='true'>Dismiss</button>
                <button class='btn btn-danger delete-item'>Delete</button>
              </div>
            </div>"
        $modal.find(".delete-item").click ->
            $form = $.createForm "DELETE", ""
            $.ajax $target.data("delete-path"),
                type: "POST"
                data: $form.serialize()
                success: (result) ->
                    $form.remove()
                    $modal.modal "hide"
                    $.standardChecks result
                    $target.remove()
                error: ->
                    $form.remove()
                    $modal.modal "hide"
                    $.showError "Drat, something went wrong!"
        $("body").append $modal
        $modal.on "hidden", ->
            $modal.remove()
        $modal.modal()
        false

$.setupNewGoal = () ->
    $(document).on "click", ".create-goal", ->
        $form = $.createForm "POST", "
            <input type='text' name='label' placeholder='a long-term goal' />", ->
            $form.remove()
            $br.remove()
        $br = $ "<br />"
        $form.after $br
        $input = $form.find "input[name='label']"
        $form.submit ->
            $.ajax $("#create_goal_path").val(),
                type: "POST"
                data: $(@).serialize()
                success: (result) ->
                    $form.remove()
                    $br.remove()
                    $.standardChecks result
                error: ->
                    $form.remove()
                    $br.remove()
                    $.showError "Drat, something went wrong!"
            false
        $(@).before $form
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
        new_task_path = $(@).data "new-task-path"
        $form = $.createForm "POST", "
            <input type='text' name='label' placeholder='a task towards this goal' />", ->
            $form.remove()
            $br.remove()
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
        $form = $.createForm "PUT", "
            <input type='hidden' name='toggle' value='true' />"
        $(@).before $form
        $.ajax $(@).data("toggle-task-path"),
            type: "POST"
            data: $form.serialize()
            success: (result) ->
                $form.remove()
                $.standardChecks result
            error: ->
                $form.remove()
                $.showError "Drat, something went wrong!"
        false

$.setupNewWeapon = () ->
    $(document).on "click", ".create-weapon", ->
        $form = $.createForm "POST", "
            <input type='text' name='label' placeholder='a skill you have' />", ->
            $form.remove()
            $br.remove()
        $br = $ "<br />"
        $form.after $br
        $input = $form.find "input[name='label']"
        $form.submit ->
            $.ajax $("#create_weapon_path").val(),
                type: "POST"
                data: $(@).serialize()
                success: (result) ->
                    $form.remove()
                    $br.remove()
                    $.standardChecks result
                error: ->
                    $form.remove()
                    $br.remove()
                    $.showError "Drat, something went wrong!"
            false
        $(@).before $form
        $form.show()
        $input.focus()
        false

$.setupEditWeapon = () ->
    $(document).on "click", ".increase-tome-item,.decrease-tome-item", ->
        type = "decrease"
        type = "increase" if $(@).is ".increase-tome-item"
        $form = $.createForm "POST", "
            <input type='hidden' name='#{type}' value='true' />"
        $(@).before $form
        $target = $ "##{$(@).data("for")}"
        $.ajax $target.data("edit-path"),
            type: "PUT"
            data: $form.serialize()
            success: (result) ->
                $form.remove()
                if result.new_weapon_bonus?.length
                    $target.text result.new_weapon_bonus
                $.standardChecks result
            error: ->
                $form.remove()
                $.showError "Drat, something went wrong!"
        false

$ ->
    $.rumble()
    if $.canEdit()
        $.setupEdits()
        $.setupBarControls()
        $.setupDeletes()
        $.setupNewGoal()
        $.setupGoals()
        $.setupNewTask()
        $.setupToggleTasks()
        $.setupNewWeapon()
        $.setupEditWeapon()
