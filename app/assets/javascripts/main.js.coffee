# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
display_articles = () ->
  arts = window.pair
  $('.article.first .title').text(arts[0].title)
  $('.article.first a.wikilink').attr('href', "http://en.wikipedia.org#{arts[0].url}")
  $('.article.second .title').text(arts[1].title)
  $('.article.second a.wikilink').attr('href', "http://en.wikipedia.org#{arts[1].url}")
  $('.article .title').unbind 'click'
  $('.article .title').bind 'click', (e) ->
    $('.article .title').unbind 'click'
    e.preventDefault()
    check_answer $(this).text()

enough_articles = true

get_articles = (fn) ->
  console.log "fetching..."
  $.get '/articles.json', null, (data) ->
    data = data.map (e) -> JSON.parse(e)
    window.articles = data.concat(window.articles)
    console.log "Now have #{window.articles.length}"
    fn()

next_articles = () ->
  enough_articles = articles.length >= 2
  if articles.length <= 8
    get_articles () ->
      console.log "done"
  if enough_articles
    window.pair = [window.articles.pop(), window.articles.pop()]
  else
    setTimeout(next_articles, 2000)
  display_articles()
  
check_answer = (answer) ->
  if window.pair[0].title == answer
    choice = 0
  else
    choice = 1
  if window.pair[choice].kincaid >= window.pair[choice^1].kincaid
    score = 1
  else
    score = 0
  update_score(score)
  show_stats choice^1^score
  setTimeout(clear_answer, 400)

clear_answer = () ->
  $('.articles').unbind 'click'
  $('.articles').bind 'click', () ->
    $('.articles').unbind 'click'
    $('.results').slideUp 200, () ->
      $('.btn-success').removeClass('btn-success')
      $('.btn-danger').removeClass('btn-danger')
    setTimeout(next_articles, 400)

show_stats = (choice) ->
  for n in [0, 1]
    $('.results').eq(n).slideUp 200, () ->
        $('.results .number').eq(n).text(Number((window.pair[n].kincaid).toFixed(1)))
      $('.results').eq(n).slideDown()
  $('.title').eq(choice).addClass('btn-success')
  $('.title').eq(choice^1).addClass('btn-danger')

total_score = 0
total_tries = 0
longest_chain = 0
current_chain = 0
correct = 0.0

update_score = (p) ->
  total_tries += 1
  total_score += p
  if p == 1
    current_chain += 1
    if longest_chain < current_chain
      longest_chain = current_chain
  else
    current_chain = 0
  correct = Number(100.0 * total_score / total_tries).toFixed(0)
  $('.score').text "Score: #{total_score}"
  $('.currentchain').text "Current Chain: #{current_chain}"
  $('.longestchain').text "Longest Chain: #{longest_chain}"
  $('.correct').text "Correct: #{correct}%"

$ ->
  next_articles()