$ ->

  $('[data-toggle="tooltip"]').tooltip()

  $('[data-toggle="popover"]').popover()

  root_url = 'http://localhost:4000'


  gotoPageUploadCSV = () ->
    $('#sign-out-button').removeClass('hide')
    $('#login-signup').slideUp()
    $('#upload-csv').removeClass('hide').slideDown()

  init = () ->
    if loggedIn()
      gotoPageUploadCSV()
  init()

  signOut = () ->
    $('#sign-out-button').addClass('hide')
    $('#login-signup').slideDown()
    $('#upload-csv').addClass('hide').slideUp()

    reqSignOut = $.ajax
      url: root_url + '/auth/sign_out',
      headers: { 'access-token': getCookie('access-token'), 'uid': getCookie('uid'), 'client': getCookie('client') },
      method: 'DELETE'
    reqSignOut.done (data) ->
      console.log data
      console.log 'success'
      setCookie('access-token', '', Date.now())
      setCookie('client', '', Date.now())
      setCookie('uid', '', Date.now())
      setCookie('expiry', '', Date.now())
      setCookie('token-type', '', Date.now())

    reqSignOut.fail (xhr) ->
      console.log $.parseJSON(xhr.responseText)
      console.log 'failure'

  signIn = (jqXHR) ->
    expiry = jqXHR.getResponseHeader('Expiry')
    setCookie('access-token', jqXHR.getResponseHeader('Access-Token'), expiry)
    setCookie('client', jqXHR.getResponseHeader('Client'), expiry)
    setCookie('uid', jqXHR.getResponseHeader('Uid'), expiry)
    setCookie('expiry', jqXHR.getResponseHeader('Expiry'), expiry)
    setCookie('token-type', jqXHR.getResponseHeader('Token-Type'), expiry)


  $('#reg-submit').on 'click', (e) ->
    e.preventDefault()
    $('.alert.alert-warning').remove()
    form = $('#registerForm')

    reqRegister = $.post root_url + '/auth/',
      email: $('.email', form).val()
      password: $('.password',form).val()
      password_confirmation: $('.password_confirmation',form).val()

    reqRegister.done (data) ->
      console.log data
      console.log 'success'

    reqRegister.fail (xhr) ->
      message = $.parseJSON(xhr.responseText).errors.full_messages[0]
      messageHTML = '<div class="alert alert-warning alert-dismissible fade in" role="alert"><button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">×</span></button>'+ message + '</div>'
      $('#error-messages').prepend(messageHTML)
      console.log 'failure'


  $('#login-button').on 'click', (e) ->
    e.preventDefault()
    $('.alert.alert-warning').remove()
    form = $('#login-form')

    reqRegister = $.post root_url + '/auth/sign_in',
      email: $('.email', form).val()
      password: $('.password',form).val()

    reqRegister.done (data, textStatus, jqXHR) ->
      signIn(jqXHR)
      gotoPageUploadCSV()
      console.log 'success'

    reqRegister.fail (xhr) ->
      message = $.parseJSON(xhr.responseText).errors[0]
      messageHTML = '<div class="alert alert-warning alert-dismissible fade in" role="alert"><button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">×</span></button>'+ message + '</div>'
      $('#login-error-messages').prepend(messageHTML)
      console.log 'failure'


  $('#sign-out-button').on 'click', (e) ->
    e.preventDefault()
    signOut()


  $('#file', '#fileUploadForm').fileupload
    dataType: 'json',
    url: root_url + '/upload_csv',
    type: 'POST',
    xhrFields: {withCredentials: true},
    headers: { 'access-token': getCookie('access-token'), 'uid': getCookie('uid'), 'client': getCookie('client'), 'token-type': getCookie('token-type'), 'expiry': getCookie('expiry') },
    add: (e, data) ->
      $('#fileUploadFormSubmitButton').val('Uploading...')
      data.submit()

    done: (e, data) ->
      signIn(data.jqXHR)
      console.log data.result
      console.log data.textStatus
      $('#fileUploadFormSubmitButton').val('Upload')
      $('#file', '#fileUploadForm').empty()
#      $('#fileUploadForm').fileupload('enable')
