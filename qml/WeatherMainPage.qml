import QtQuick 2.5
import QtQuick.Controls 1.2
import QtQuick.XmlListModel 2.0
import QtLocation 5.5
import QtPositioning 5.5
import VPlayApps 1.0


Page {
    id:mainPage

    property string longitude: "null"//"2.352222"
    property string latitude: "null"//"48.856614"

    property string woeid: "null"
    property string city: "null"
    property string countryCode: "null"

    property int dayLowTemp: 0
    property int dayHighTemp: 0

    property string dayHumidity: "null"
    property string dayVisibility: "null"

    property string dayCode1: "0"
    property string dayLowTemp1: "null"
    property string dayHighTemp1: "null"

    property string dayCode2: "0"
    property string dayLowTemp2: "null"
    property string dayHighTemp2: "null"

    property string dayCode3: "0"
    property string dayLowTemp3: "null"
    property string dayHighTemp3: "null"

    property string dayCode4: "0"
    property string dayLowTemp4: "null"
    property string dayHighTemp4: "null"

    property string dayCode5: "0"
    property string dayLowTemp5: "null"
    property string dayHighTemp5: "null"

    property string dayLowDescription: "null"
    property string dayHighDescription: "null"

    property string tempCurrency: "°C"
    property string tempDevise: "c"

    property var today: alldata[currentIndex]
    property int currentIndex: 0

    property var alldata: [
      { temperature: dayLowTemp, description: qsTr(dayLowDescription)},
      { temperature: dayHighTemp, description: qsTr(dayHighDescription)}
    ]

    Component.onCompleted:
    {
        var coord = src.position.coordinate;
        //Get Long & Lat
        if(mainPage.latitude === "null" && mainPage.longitude === "null"){
            mainPage.latitude = coord.latitude
            mainPage.longitude = coord.longitude
            console.log("Position top val set.")
        }
        getLocation();
        getWeatherData();
    }

    PositionSource{
        id: src
        updateInterval: 1000
        active: true
        preferredPositioningMethods: PositionSource.SatellitePositioningMethods

        Component.onCompleted: {
            /*var supPos  = "Unknown"
            if (src.supportedPositioningMethods == PositionSource.NoPositioningMethods)
                 supPos = "NoPositioningMethods"
            else if (src.supportedPositioningMethods == PositionSource.AllPositioningMethods)
                 supPos = "AllPositioningMethods"
            else if (src.supportedPositioningMethods == PositionSource.SatellitePositioningMethods)
                 supPos = "SatellitePositioningMethods"
            else if (src.supportedPositioningMethods == PositionSource.NonSatellitePositioningMethods)
                 supPos = "NonSatellitePositioningMethods"

            console.log("Position Source Loaded || Supported: "+supPos+" Valid: "+valid)*/
        }
        onPositionChanged: {
            var coord = src.position.coordinate;
            console.log("Coordinate:", coord.longitude, coord.latitude);

            //Get JSON Location
            request('http://query.yahooapis.com/v1/public/yql?q=SELECT%20*%20FROM%20geo.places%20WHERE%20text%3D%22('+mainPage.latitude+'%2C'+mainPage.longitude+')%22%20limit%201&format=json&callback=',
            function (o) {

            // log the json response
            console.log("\n\nLocation data: "+o.responseText);
            // translate response into object
            var d = eval('new Object(' + o.responseText + ')');
            // access elements inside json object with dot notation
            woeid = d.query.results.place.woeid
            console.log("Woeid: "+ woeid)

            countryCode = d.query.results.place.country.code
            console.log("Country code: "+ countryCode)

            city = d.query.results.place.locality1.content
            console.log("City: "+ city)});

            getLocation();
            getWeatherData();
        }
    }

    // Background
    Rectangle{
      anchors.fill: parent
      gradient: Gradient{
        GradientStop {
          position: 0
          color:(today.temperature < 15 || today.temperature >= 36 && today.temperature < 59  ? "#1AD6FD" : (today.temperature > 15 && today.temperature < 20 || today.temperature > 59 && today.temperature < 68  ? "#FB6D02" : (today.temperature > 20 && today.temperature < 35 || today.temperature > 68 ? "#FF5E3A" : "#02fb6d")))
          Behavior on color { ColorAnimation { duration: 1500 } }
          }
        GradientStop{
          position: 1
          color:(today.temperature < 15 || today.temperature >= 36 && today.temperature < 59 ? "#1D62F0" : (today.temperature > 15 && today.temperature < 20 || today.temperature > 59 && today.temperature < 68 ? "#FDEC1A" : (today.temperature > 20 && today.temperature < 35 || today.temperature > 68 ? "#FF2A68" : "#01af4c")))

          Behavior on color { ColorAnimation { duration: 1000 } }
          }
      }
      MultiPointTouchArea {
         anchors.fill: parent
         minimumTouchPoints: 1
         maximumTouchPoints: 1
         touchPoints: TouchPoint{
                          id: point1
                          onPressedChanged: {
                              if(pressed)
                              {
                                  if(tempDevise == "f")
                                  {
                                      tempDevise = "c"
                                      tempCur.text = "°C"

                                      getWeatherData();
                                      animateOpacity.restart();
                                      animateOpacityV.restart();
                                  }
                                  else if(tempDevise == "c")
                                  {
                                      tempDevise = "f"
                                      tempCur.text = "°F"

                                      getWeatherData();
                                      animateOpacity.restart();
                                      animateOpacityV.restart();
                                  }
                              }

                          }
                      }
         }
    }

    // Top content
    Column
    {
      id:topContent
      anchors.horizontalCenter: parent.horizontalCenter
      y: dp(10)
      spacing: dp(10)

      // Current time
      AppText
      {
        id: timeLabel
        color:"white"
        font.pixelSize: sp(14)
        anchors.horizontalCenter: parent.horizontalCenter

        Timer
        {
          running: true
          interval: 1000 * 30
          triggeredOnStart: true
          repeat: true
          onTriggered: timeLabel.text = new Date().toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
        }
      }

      // City
      AppText
      {
        id:textLocation
        text: mainPage.city+","+mainPage.countryCode
        color:"white"
        font.pixelSize: sp(22)
        anchors.horizontalCenter: parent.horizontalCenter

        //More weather infos
        AppText{
            id:textWeatherDetailsHum
            anchors.left: parent.left
            anchors.leftMargin: -190
            anchors.top: parent.bottom
            anchors.topMargin: 70
            font.pixelSize: sp(14)
            text: "Humidity: "+ dayHumidity + "%"
            color:"white"

            Icon{
                 id:iconHum
                 color:"white"
                 anchors.left: textWeatherDetailsHum.right
                 anchors.leftMargin: 10
                 anchors.top: textWeatherDetailsHum.top
                 anchors.topMargin: 3
                 icon:IconType.tint
                 size: dp(15)
            }
        }
        AppText{
            id:textWeatherDetailsVisi
            anchors.left: parent.left
            anchors.leftMargin: -190
            anchors.top: textWeatherDetailsHum.bottom
            anchors.topMargin: 10
            font.pixelSize: sp(14)
            text: "Visibility: "+ dayVisibility + "km"
            color:"white"

            //Opacity changer
            NumberAnimation {
                id: animateOpacityV
                target: textWeatherDetailsVisi
                properties: "opacity"
                from: 0.00
                to: 1.0
                easing {type: Easing.InQuad; overshoot: 900}
           }

            Icon{
                 id:iconVisi
                 color:"white"
                 anchors.left: textWeatherDetailsVisi.right
                 anchors.leftMargin: 10
                 anchors.top: textWeatherDetailsVisi.top
                 anchors.topMargin: 3
                 icon:IconType.road
                 size: dp(15)
            }
        }
      }
    }

    // Centered content
    Column {
      id: col
      anchors.centerIn: parent

      // Temperature
      AppText {
        id: tempText
        color:"white"
        property int temperature: today.temperature

        Component.onCompleted: text = temperature
        font.pixelSize: sp(140)
        anchors.horizontalCenter: parent.horizontalCenter

        onTemperatureChanged:{
          var currentTemp = parseInt(tempText.text)
          textTimer.restart()
        }
        //Decompte de la température
        Timer{
          id: textTimer
          interval: 40

          onTriggered:
          {
            // Check if we have to change the text
            var currentTemp = parseInt(tempText.text)

            if (tempText.temperature > currentTemp)
            {
              tempText.text = ++currentTemp
              restart()
            }
            else if (tempText.temperature < currentTemp)
            {
              tempText.text = --currentTemp
              restart()
            }
          }
        }

        //Tempcurrency
        AppText
        {
          id: tempCur
          color:"white"
          text:
          {
              if(Qt.locale().name.substring(0,2) === "us"){
                    tempDevise = "f"
                    text = tempCurrency = "°F"
              }
              else{
                    tempDevise = "c"
                    text = tempCurrency = "°C"
              }
          }
          font.pixelSize: sp(90)
          anchors.left: tempText.right
          anchors.leftMargin: 10
          //Opacity changer
          NumberAnimation {
              id: animateOpacity
              target: tempCur
              properties: "opacity"
              from: 0.00
              to: 1.0
              easing {type: Easing.InQuad; overshoot: 500}
         }
        }
      }


      // Description
      AppText
      {
        id: descText
        text: today.description
        color:"white"
        font.pixelSize: sp(28)
        //font.family: normalFont.name
        anchors.horizontalCenter: parent.horizontalCenter
        //Opacity changer
        Behavior on text
        {
          SequentialAnimation
          {
            NumberAnimation { target: descText; property: "opacity"; to: 0 }
            PropertyAction { }
            NumberAnimation { target: descText; property: "opacity"; to: 1 }
          }
        }
      }
    }

    // Bottom content
    Grid {
      id: bottomGrid

      width: Math.min(parent.width - dp(20), dp(450))
      anchors.horizontalCenter: parent.horizontalCenter
      y: parent.height - height - dp(10)
      columns: 5

      Repeater {

        function getTomorrow(days){
        var today = new Date();
        today.setDate(today.getDate()+days)
        return Qt.formatDate(today, "dddd");
       }

       function dayCodeComparaison(days){
           //Si les day code ne sont pas egale a rien
               if(days === "0")
                   return IconType.exclamationtriangle
               else if(days === "1")
                   return IconType.bolt
               else if(days === "2")
                   return IconType.exclamationtriangle
               else if(days === "3")
                   return IconType.bolt
               else if(days === "4")
                   return IconType.bolt
               else if(days === "5")
                   return IconType.umbrella
               else if(days === "6")
                   return IconType.umbrella
               else if(days === "7")
                   return IconType.umbrella
               else if(days === "8")
                   return IconType.tint
               else if(days === "9")
                   return IconType.tint
               else if(days === "10")
                   return IconType.tint
               else if(days === "11")
                   return IconType.umbrella
               else if(days === "12")
                   return IconType.umbrella
               else if(days === "13")
                   return IconType.asterisk
               else if(days === "14")
                   return IconType.asterisk
               else if(days === "15")
                   return IconType.asterisk
               else if(days === "16")
                   return IconType.asterisk
               else if(days === "17")
                   return IconType.exclamationtriangle
               else if(days === "18")
                   return IconType.asterisk
               else if(days === "19")
                   return IconType.leaf
               else if(days === "20")
                   return IconType.cloud
               else if(days === "21")
                   return IconType.cloud
               else if(days === "22")
                   return IconType.cloud
               else if(days === "23")
                   return IconType.leaf
               else if(days === "24")
                   return IconType.leaf
               else if(days === "25")
                   return IconType.asterisk
               else if(days === "26")
                   return IconType.cloud
               else if(days === "27")
                   return IconType.cloud
               else if(days === "28")
                   return IconType.cloud
               else if(days === "29")
                   return IconType.cloud
               else if(days === "30")
                   return IconType.cloud
               else if(days === "31")
                   return IconType.cloud
               else if(days === "32")
                   return IconType.suno
               else if(days === "33")
                   return IconType.suno
               else if(days === "34")
                   return IconType.suno
               else if(days === "35")
                   return IconType.umbrella
               else if(days === "36")
                   return IconType.fire
               else if(days === "37")
                   return IconType.bolt
               else if(days === "38")
                   return IconType.bolt
               else if(days === "39")
                   return IconType.bolt
               else if(days === "40")
                   return IconType.umbrella
               else if(days === "41")
                   return IconType.asterisk
               else if(days === "42")
                   return IconType.umbrella
               else if(days === "43")
                   return IconType.asterisk
               else if(days === "44")
                   return IconType.cloud
               else if(days === "45")
                   return IconType.bolt
               else if(days === "46")
                   return IconType.asterisk
               else if(days === "47")
                   return IconType.bolt
               else if(days === "3200")
                   return IconType.question
       }

        model: [
          { day: getTomorrow(1), high: dayHighTemp1, low: dayLowTemp1, icon: dayCodeComparaison(dayCode1) },
          { day: getTomorrow(2), high: dayHighTemp2, low: dayLowTemp2, icon: dayCodeComparaison(dayCode2) },
          { day: getTomorrow(3), high: dayHighTemp3, low: dayLowTemp3, icon: dayCodeComparaison(dayCode3) },
          { day: getTomorrow(4), high: dayHighTemp4, low: dayLowTemp4, icon: dayCodeComparaison(dayCode4) },
          { day: getTomorrow(5), high: dayHighTemp5, low: dayLowTemp5, icon: dayCodeComparaison(dayCode5) }
        ]

        Column {
          width: bottomGrid.width / 5
          spacing: dp(5)

          Icon {
            icon: modelData.icon
            color:"white"
            anchors.horizontalCenter: parent.horizontalCenter
            size: dp(20)
          }

          Item {
            width: 1
            height: dp(5)
          }

          AppText {
            text: modelData.high
            color:"white"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: sp(14)
          }

          AppText {
            text: modelData.low
            color: "#aaffffff"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: sp(14)
          }

          Item {
            width: 1
            height: dp(5)
          }

          AppText {
            text: modelData.day
            color:"white"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: sp(14)
          }
        }
      }
    }

    //Repeat Centreed Anim
    Timer
    {
      interval: 3500
      repeat: true
      running: true
      onTriggered: {
        if (currentIndex < alldata.length - 1)
          currentIndex++
        else
          currentIndex = 0
      }
    }

    Timer {
        id: networkTimer
        triggeredOnStart : true
        interval: 2000
        repeat: true
        running: true
        onTriggered:
        {
            if(isOnline == false){
                /*InputDialog.confirm(app, "Network error", function(ok) {
                        if(ok) {
                            getLocation();
                            getWeatherData();
                        }
                      })*/
                networkDialog.open()
            }
            else{
                getLocation();
                getWeatherData();
            }

        }
    }


    //Network dialog error
    Dialog{
        id: networkDialog

        title: "Network error"
        positiveActionLabel: "Retry"
        negativeActionLabel: "Cancel"
        onCanceled: close()
        onAccepted: {
            getLocation();
            getWeatherData();
            close()
        }

        AppText{
            id:netowkText
            anchors.fill: parent
            anchors.centerIn:parent
            anchors.leftMargin:25
            //anchors.verticalCenter : parent
            text:"Please check your mobile network settings and try again."
        }
    }

    // JSON function
    function request(url, callback) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = (function(myxhr) {
            return function() {
                if(myxhr.readyState === 4) callback(myxhr)
            }
        })(xhr);
        xhr.open('GET', url, true);
        xhr.send('');
    }

    function getWeatherData(){
        //Get JSON Weather data
        request('http://query.yahooapis.com/v1/public/yql?q=SELECT%20*%20FROM%20weather.forecast%20WHERE%20woeid%3D%22'+mainPage.woeid+'%22%20and%20u%3D%22'+tempDevise+'%22&format=json&callback=',
        function (o) {

            // log the json response
            console.log("\n\nWeather data: "+o.responseText);
            // translate response into object
            var d = eval('new Object(' + o.responseText + ')');
            // access elements inside json object with dot notation

            dayLowTemp = d.query.results.channel.item.forecast[0].low
            dayHighTemp = d.query.results.channel.item.forecast[0].high
            console.log("Current day high: "+ dayHighTemp)
            console.log("Current day low: "+ dayLowTemp+ "\n\n")

            dayLowDescription = d.query.results.channel.item.forecast[0].text
            dayHighDescription = d.query.results.channel.item.forecast[0].text

            dayCode1 = d.query.results.channel.item.forecast[1].code
            dayLowTemp1 = d.query.results.channel.item.forecast[1].low
            dayHighTemp1 = d.query.results.channel.item.forecast[1].high
            console.log("dayCode 1: "+ dayCode1)
            console.log("dayLowTemp 1: "+ dayLowTemp1)
            console.log("dayHighTemp 1: "+ dayHighTemp1 + "\n\n")

            dayCode2 = d.query.results.channel.item.forecast[2].code
            dayLowTemp2 = d.query.results.channel.item.forecast[2].low
            dayHighTemp2 = d.query.results.channel.item.forecast[2].high
            console.log("dayCode 2: "+ dayCode2)
            console.log("dayLowTemp 2: "+ dayLowTemp2)
            console.log("dayHighTemp 2: "+ dayHighTemp2 + "\n\n")

            dayCode3 = d.query.results.channel.item.forecast[3].code
            dayLowTemp3 = d.query.results.channel.item.forecast[3].low
            dayHighTemp3 = d.query.results.channel.item.forecast[3].high
            console.log("dayCode 3: "+ dayCode3)
            console.log("dayLowTemp 3: "+ dayLowTemp3)
            console.log("dayHighTemp 3: "+ dayHighTemp3 + "\n\n")

            dayCode4 = d.query.results.channel.item.forecast[4].code
            dayLowTemp4 = d.query.results.channel.item.forecast[4].low
            dayHighTemp4 = d.query.results.channel.item.forecast[4].high
            console.log("dayCode 4: "+ dayCode4)
            console.log("dayLowTemp 4: "+ dayLowTemp4)
            console.log("dayHighTemp 4: "+ dayHighTemp4 + "\n\n")

            dayCode5 = d.query.results.channel.item.forecast[5].code
            dayLowTemp5 = d.query.results.channel.item.forecast[5].low
            dayHighTemp5 = d.query.results.channel.item.forecast[5].high
            console.log("dayCode 5: "+ dayCode5)
            console.log("dayLowTemp 5: "+ dayLowTemp5)
            console.log("dayHighTemp 5: "+ dayHighTemp5+ "\n\n")

            dayHumidity = d.query.results.channel.atmosphere.humidity
            dayVisibility = d.query.results.channel.atmosphere.visibility
            console.log("dayHumidity: "+ dayHumidity)
            console.log("dayVisibility: "+ dayVisibility+ "\n\n")

            if(city === "null"){
                city = d.query.results.channel.location.city
                console.log("City: "+ city+ "\n\n")

            }


            if(tempDevise === "c")
                textWeatherDetailsVisi.text = "Visibility: "+ dayVisibility + "km"
            else
                textWeatherDetailsVisi.text = "Visibility: "+ dayVisibility + "mi"
        });
    }

    function getLocation(){
        //Get JSON Location
        request('http://query.yahooapis.com/v1/public/yql?q=SELECT%20*%20FROM%20geo.places%20WHERE%20text%3D%22('+mainPage.latitude+'%2C'+mainPage.longitude+')%22%20limit%201&format=json&callback=',
        function (o) {

        // log the json response
        console.log("\n\nLocation data: "+o.responseText);
        // translate response into object
        var d = eval('new Object(' + o.responseText + ')');
        // access elements inside json object with dot notation
        woeid = d.query.results.place.woeid
        console.log("Woeid: "+ woeid)

        countryCode = d.query.results.place.country.code
        console.log("Country code: "+ countryCode)

        city = d.query.results.place.locality1.content
        console.log("City: "+ city)


        getWeatherData();
        });
    }
}

