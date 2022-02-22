<img src="/assets/sunpatch.png" height="128">

Sunpatch is a Flutter-based app for monitoring personal UV exposure.

## How it works

On the main screen, the user can register, login to an existing account, or temporarily login as an anonymous user.
Firebase is used for authentication as well as data storage.

As part of the registration process, the user must inform their Fitzpatrick skin phototype, which will be used in determining their maximum daily recommended exposure to UV radiation.

<img src="https://i.ibb.co/Fg6h23c/home.png" alt="home" width="250"> <img src="https://i.ibb.co/tMhN0XT/register.png" alt="register" width="250"> <img src="https://i.ibb.co/HKYdZvh/skin.png" alt="skin" width="250">

After logging in, the user can opt to start monitoring UV radiation every time they are outside or in an otherwise sun-exposed situation.

GPS data is used along with the [OpenWeather](https://openweathermap.org/) API to determine the current UVI (UV index) at the user's location. The UVI is used to calculate the amount of UV exposure over time, and while monitoring, this amount is accumulated and shown as a percentage of the maximum daily exposure recommended (as determined by the user's Fitzpatrick skin type).

<img src="https://i.ibb.co/5ML92XR/monitoring1.png" alt="monitoring1" width="250"> <img src="https://i.ibb.co/3sT1Hyt/monitoring2.png" alt="monitoring2" width="250"> <img src="https://i.ibb.co/9h7ct75/monitoring3.png" alt="monitoring3" width="250">

## Running the app

To run or install the app, you'll first need to create the file `assets/api_key`, containing (only) a valid [OpenWeather](https://openweathermap.org/) API key.

Build and run with [Flutter](https://github.com/flutter/flutter).
