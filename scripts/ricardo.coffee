# Description
#   Test some things for Hubots.
#
# Configuration:
#   None
#
# Commands:
#   hubot Ricardo teste
#   
#
# Author:
#   
#   
#
imagens = [
	"http://sorisomail.com/img/1435477714895.jpg",
	"http://topimagensengracadas.com/indo-para-a-escola-sem-o-exercicio"
	]
util = require 'util'
querystring = require('querystring')
pesquisa = [null]

listaHoteisPesquisa = []
listaservicos = []
servicosGlobal = []
numeroHotelEscolhido = null
    
module.exports = (robot) ->

  robot.hear /Ola/i, (msg) ->
   msg.send "Ola Ola"
	
  robot.respond /Ricardo (.*) de portas/i, (res) ->
   doorType = res.match[1]
   if doorType is "não sabe nada"
    res.reply "I'm afraid I can't let you do that."
   else
    res.reply "Opening experiment #{doorType} doors"

  robot.hear /What is your name?/i, (res) ->
   res.send "I am the hubot..."
   
  robot.hear /tired|too hard|to hard|upset|bored/i, (msg) ->
   msg.send "Tenta mais"
   
  robot.hear /imagens/i, (msg) ->
   msg.send msg.random imagens
   
  robot.respond /gem whois (.*)/i, (msg) ->
    gemname = escape(msg.match[1])
    msg.http("http://rubygems.org/api/v1/gems/#{gemname}.json")
      .get() (err, res, body) ->
        try
          json = JSON.parse(body)
          msg.send "   gem name: #{json.name}\n
     owners: #{json.authors}\n
       info: #{json.info}\n
    version: #{json.version}\n
  downloads: #{json.downloads}\n"
        catch error
          msg.send "Gem not found. It will be mine. Oh yes. It will be mine."
          
      
   robot.hear /check domain (.*)/i, (msg) ->
    domain = escape(msg.match[1])
    user = process.env.DNSIMPLE_USERNAME
    pass = process.env.DNSIMPLE_PASSWORD
    auth = 'Basic ' + new Buffer(user + ':' + pass).toString('base64');
    msg.http("https://dnsimple.com/domains/#{domain}/check")
      .headers(Authorization: auth, Accept: 'application/json')
      .get() (err, res, body) ->
        switch res.statusCode
          when 200
            msg.send "Sorry, #{domain} is not available."
          when 404
            msg.send "Cybersquat that s***!"
          when 401
            msg.send "You need to authenticate by setting the DNSIMPLE_USERNAME & DNSIMPLE_PASSWORD environment variables"
          else
            msg.send "Unable to process your request and we're not sure why"
   
   # Metodo para defenir respostas nas entradas e saidas de utilizadors
   enterReplies = ['Bom dia 2', 'Target Acquired 2', 'Firing 2', 'Hello friend 2.', 'Gotcha 2', 'I see you 2']
   leaveReplies = ['Are you still there 2?', 'Target lost 2', 'Searching 2']

   robot.enter (res) ->
    res.send res.random enterReplies
   robot.leave (res) ->
    res.send res.random leaveReplies

  answerTest = process.env.HUBOT_TESTE_RICARDO
  
  
  robot.respond /RC env/, (env) ->
    res.send "#{answerTest}, test"
    
  irritaIntervalId = true

  robot.hear /comeca a chatear/, (res) ->
    if irritaIntervalId
      console.log('someone connected!')
      res.send "Ja está"
      irritaIntervalId = null
      return

    res.send "Hey, want to hear the most annoying sound in the world?"
    irritaIntervalId = setInterval () ->
      res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
    , 1000
    
    robot.hear /ja chega/i, (res) ->        
     if irritaIntervalId
       res.send "GUYS, GUYS, GUYS!"
       clearInterval(irritaIntervalId)
       irritaIntervalId = null
     else
       res.send "Not annoying you right now, am I?"
       
  robot.respond /FAKE EVENT (.*)/i, (msg) ->
    msg.send "fake event '#{msg.match[1]}' triggered"
    robot.emit msg.match[1], {user: msg.message.user}

  robot.on 'debug', (event) ->
    robot.send event.user, util.inspect event
    

  robot.router.get "/hubot/say", (req, res) ->
    query = querystring.parse(req._parsedUrl.query)
    message = query.message

    user = {}
    user.room = query.room if query.room

    robot.send(user, message)
    res.end "said #{message}"
  
 # ListaPalavras='uma'
  robot.hear /adiciona/i, (palavra) ->
    setTimeout () ->
      palavra.send "comeca a chatear \n"
    , 10 * 100
    palavra.send "@rdvc comeca a chatear"
    
   # ListaPalatvras += '#{palavra.match[1]}'
   # console.log(ListaPalavras)
    
  robot.hear /teste/i, (tst) ->
    tst.send "rdvc: ja chega"

  robot.respond /tu es lento/, (res) ->
     setTimeout () ->
       res.send "rdvc: teste"
     , 10 * 1000
	 
	 
#   Pesquisa hotel por nome ou por local
 
  robot.respond /(?:hotel|htl)(?: me)? (.*)/i, (msg) ->
    nam =null
    robot.http("https://api2.b-guest.com:443/api/v2/hotels?search=#{msg.match[1]}")
      .get() (err, res, body) ->
         nam = JSON.parse(body)
         um = 0
         listaHoteisPesquisa=nam
         listImp = []
         for hotel of nam
           listImp.push " #{um}: #{nam[um].name}\n"
           um+=1
         msg.send " #{listImp}"
               
           
  #Guarda hotel escolhido
   robot.respond /(?:escolher hotel|escHtl)(?: me)? (.*)/i, (msg) ->
         numeroHotelEscolhido = msg.match[1]
         msg.send "#{numeroHotelEscolhido} : #{listaHoteisPesquisa[numeroHotelEscolhido].name}"
         
    
      
   # Escolher um hotel pelo numero e devolve que instalações extra tem     
  robot.respond /(?:hotel_Number|htlNr)(?: me)? (.*)/i, (msg) ->
    query = msg.match[1]
    msg.send "https://api2.b-guest.com:443/api/v2/hotels/#{query}"
    robot.http("https://api2.b-guest.com:443/api/v2/hotels/#{query}")
      .get() (err, res, body) ->
        hotel = JSON.parse(body)
        msg.send " #{hotel.facilities[0]}"
        numnr = 0
        for util of hotel.facilities
          msg.send " name: #{hotel.facilities[numnr].name} :
              description: #{hotel.facilities[numnr].description}"
          num +=1

                                    
 # Escolher um hotel pelo numero e devolver serviços     
  robot.respond /(?:hotel_Service|htlsrv)/i, (msg) ->
    robot.http("https://api2.b-guest.com:443/api/v2/hotels/#{listaHoteisPesquisa[numeroHotelEscolhido].id}/subservices")
      .get() (err, res, body) ->
        hotel = JSON.parse(body)
        listaservicos = hotel
        numhsrv = 0
        listImp = []
        listImp.push "Hotel Name: #{listaHoteisPesquisa[numeroHotelEscolhido].name}\n"
        for util of hotel
        #  serviceMe ( msg, numhsrv)
        # msg.send "#{numhsrv}: #{hotel[numhsrv].name}\n #{hotel[numhsrv].imageUrl}\n "
          imprimeLista(msg, numhsrv, "#{numhsrv}: #{hotel[numhsrv].name}\n")
          imprimeLista(msg, numhsrv, "#{hotel[numhsrv].imageUrl}\n ")
          
          numhsrv +=1
          #listImp.push "#{numhsrv}: #{hotel[numhsrv].name}\n #{hotel[numhsrv].imageUrl}\n "
         
        msg.send "#{listImp}"
          
    # Escolher um servico e devolve os subserviços    
  robot.respond /(?:escolha_Serviço|escsrv) ?(.*)/i, (msg) ->
   # msg.send "https://api2.b-guest.com:443/api/v2/subservices/132?includeProductOptions=false"
   # msg.send "https://api2.b-guest.com:443/api/v2/subservices/#{listaservicos[msg.match[1]].id}?includeProductOptions=false"
   # robot.http("https://api2.b-guest.com:443/api/v2/subservices/#{listaservicos[msg.match[1]].id}?includeProductOptions=false")
     robot.http("https://api2.b-guest.com:443/api/v2/subservices/#{listaservicos[msg.match[1]].id}?includeProductOptions=false")
      .get() (err, res, body) ->
        product = JSON.parse(body)
        servicosGlobal = product
        numsrv = 0
        # listImp = []
        # listImp.push " Servico : #{servicosGlobal.name}\n"
        for util of servicosGlobal.categories[0].products
         # listImp.push "#{numsrv}: #{servicosGlobal.categories[0].products[numsrv].name }\n "
         # listImp.push "#{numsrv}: #{servicosGlobal.categories[0].products[numsrv].imageUrl }\n "
          imprimeLista(msg, numsrv, "#{numsrv}: #{servicosGlobal.categories[0].products[numsrv].name } ")
          if servicosGlobal.categories[0].products[numsrv].imageUrl isnt null   
            imprimeLista(msg, numsrv, "#{servicosGlobal.categories[0].products[numsrv].imageUrl }\n ")
          numsrv +=1
         # msg.send "#{listImp}"
  
 # Função que permite fazer um compasso de espera no envio de mensagens      
  imprimeLista = (msg, num, texto) ->
    setTimeout () ->
      msg.send "#{texto}"
    , num*1000