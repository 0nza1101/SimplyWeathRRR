# SimplyWeathRRR
A weather app made with the V-Play SDK (Qt framework based).
[V-PLAY SDK](http://v-play.net/)

This app is based on the V-Play SDK app demo http://v-play.net/doc/v-play-appdemos-weather-example/

It's add :
* Gettings current user location.
* Do JSON XMLHttpRequest with the user location.
* Parse JSON data from Yahoo Weather API.
* Dispaly the lowest and the highest temperature in °C and °F with a cool animation.
* Including a short description of the current weather state.
* Show the 5-day forecast.
* Also display the humidity in % and the visibility (miles and kilometers).

Since the Yahoo Weather API stopped working for details see [this](https://www.igorkromin.net/index.php/2016/03/27/yahoo-effectively-shut-down-its-weather-api-by-forcing-oauth-10-and-crippling-it/)
so I have found a fix to bypass this restriction.

To get location :
http://query.yahooapis.com/v1/public/yql?q=SELECT%20*%20FROM%20geo.places%20WHERE%20text%3D%22(YOURLAT%2CYOURLONG)%22%20limit%201&format=json&callback=

To get weather data :
http://query.yahooapis.com/v1/public/yql?q=SELECT%20*%20FROM%20weather.forecast%20WHERE%20woeid%3D%22YOURWOEID%22%20and%20u%3D%22YOURTEMPDEVISECorF%22&format=json&callback=

Enjoy ! :boom::boom::boom:
##TODO
- [ ] Network error msg bug need a little fix.
