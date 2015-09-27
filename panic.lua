local pin = 5
wifi.setmode(wifi.STATION)
wifi.sta.config("Startup Village","star circle north")
wifi.sta.autoconnect(1)
local HOST = "indoor.nearals.com" 
local URI = "/devEndPoint.php"
function build_post_request(host, uri, data_table)
     local data = ""
     for param,value in pairs(data_table) do
          data = data .. param.."="..value.."&"
     end
     request = "POST "..uri.." HTTP/1.1\r\n"..
     "Host: "..host.."\r\n"..
     "Connection: close\r\n"..
     "Content-Type: application/x-www-form-urlencoded\r\n"..
     "Content-Length: "..string.len(data).."\r\n"..
     "\r\n"..
     data
     print(request)  
     return request
end
local function display(sck,response)
     print(response)
end
local function send_sms(from,to,body,tri)
     local data = {
      mac = body
     }
     socket = net.createConnection(net.TCP,0)
     socket:on("receive",display)
     socket:connect(80,HOST)
     socket:on("connection",function(sck)     
          local post_request = build_post_request(HOST,URI,data)
          sck:send(post_request)
     end)     
end
function check_wifi()
 local ip = wifi.sta.getip()
 if(ip==nil) then
   print("Connecting...")
 else
  tmr.stop(0)
  print("Connected to AP!")
  print(ip)
  gpio.trig(6, "down",pin1cb)
 end
end
function debounce (func)
    local last = 0
    local delay = 200000
    return function (...)
        local now = tmr.now()
        if now - last < delay then return end
        last = now
        return func(...)
    end
end
function onChange ()
    send_sms("15551234567","12223456789",wifi.sta.getmac(),1) 
end
gpio.mode(pin, gpio.INT, gpio.PULLUP)
gpio.trig(pin, 'up', debounce(onChange))
tmr.alarm(0,2000,1,check_wifi)
