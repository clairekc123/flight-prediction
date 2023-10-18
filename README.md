# flight-prediction

<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/clairekc123/flight-prediction">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a>

<h3 align="center">DCA Flight Delay Prediction</h3>

  <p align="center">
    project_description
    <br />
    <a href="https://github.com/clairekc123/flight-prediction"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/clairekc123/flight-prediction">View Demo</a>
    ·
    <a href="https://github.com/clairekc123/flight-prediction/issues">Report Bug</a>
    ·
    <a href="https://github.com/clairekc123/flight-prediction/issues">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

[![Product Name Screen Shot][product-screenshot]](https://example.com)

I built this app as a user-friendly means to predict the chance of flight delay for flights leaving Ronald Reagan National Airport (DCA). For the scope of this project, a delayed flight is defined as a flight that arrived more than 15 minutes after the scheduled arrival time. Using a binary indicator for delay as our outcome, my peers and I developed a logistic regression model using 2021 DCA flight data over the course of the fall 2022 semester for a class project. I have extended the application of this model to predict the chance of flight delay given different predictor values in this app, with an interactive map visualization to show different flight paths. 

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Data 

1. Named `WashDCflights 2021 (1).csv`

Overall description of dataset:

This dataset contains data from 34,074 flights that departed from Reagan National Airport (DCA). 

Predictors: 
* __*month* (factor)__: month of flight: our data looks at April-August 2021
* __*day* (factor)__: weekday of flight, 1=Monday, 7=Sunday
* __*carrier* (factor)__: airline, 13 unique values
* *origin* (factor): airport origin (DCA)
* *orstate* (factor): state of flight origin (DC)
* *deststate* (factor): state of flight destination, 40 unique values
* __*depart* (numeric)__: time of scheduled flight departure in the form of number of minutes starting at 12:01 a.m. (For example: 300 = 5:00 a.m., since 300/60 = 5 hours starting at 12:01 a.m.)
* __*delay* (factor)__: flight delayed, 1= delayed, 0=not delayed (a delayed flight is defined as a flight that arrived more than 15 minutes after the scheduled arrival time)
* __*duration* (numeric)__: scheduled flight duration in minutes
* *distance* (numeric): scheduled flight distance in miles

**Bolded indicates variables present in prediction model** 

2. Named `airports.csv`

Overall description of dataset:

This dataset contains geographical information about 343 US airports. The majority of the data was sourced from kaggle.com, but was edited to include 2 missing airports present in the WashDCflights2021 dataset, HHH and ECP.

Predictors:
* *IATA* (character): 3 digit code identifying airport, 343 unique values
* *AIRPORT* (character): airport name, 343 unique values
* *CITY* (character): city where airport is located, 326 unique calues
* *STATE* (character): state where airport is located, 55 unique values
* *COUNTRY* (character): country where airport is located (USA)
* *LATITUDE* (numeric): approximate latitude coordinate of airport's location
* *LONGITUDE* (numeric): approximate longitude coordinate of airport's location
  


### Built With

* RStudio
  * R libraries utilized:
    * dplyr
    * forcats
    * caret
    * glmnet
    * pROC
    * plotly
    * ggplot2
    * RColorBrewer
* [![React][React.js]][React-url]
* [![Vue][Vue.js]][Vue-url]
* [![Angular][Angular.io]][Angular-url]
* [![Svelte][Svelte.dev]][Svelte-url]
* [![Laravel][Laravel.com]][Laravel-url]
* [![Bootstrap][Bootstrap.com]][Bootstrap-url]
* [![JQuery][JQuery.com]][JQuery-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Overview

 

This shiny app is an extension of my master's project and graduate work in my data visualization class. 

_For more examples, please refer to the [Documentation](https://example.com)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ROADMAP -->
## Roadmap

- [ ] Feature 1
- [ ] Feature 2
- [ ] Feature 3
    - [ ] Nested Feature

See the [open issues](https://github.com/clairekc123/flight-prediction/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Claire Casey -  clairekc123@gmail.com

Project Link: [https://github.com/clairekc123/flight-prediction](https://github.com/clairekc123/flight-prediction)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* []()
* []()
* []()

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/clairekc123/flight-prediction.svg?style=for-the-badge
[contributors-url]: https://github.com/clairekc123/flight-prediction/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/clairekc123/flight-prediction.svg?style=for-the-badge
[forks-url]: https://github.com/clairekc123/flight-prediction/network/members
[stars-shield]: https://img.shields.io/github/stars/clairekc123/flight-prediction.svg?style=for-the-badge
[stars-url]: https://github.com/clairekc123/flight-prediction/stargazers
[issues-shield]: https://img.shields.io/github/issues/clairekc123/flight-prediction.svg?style=for-the-badge
[issues-url]: https://github.com/clairekc123/flight-prediction/issues
[license-shield]: https://img.shields.io/github/license/clairekc123/flight-prediction.svg?style=for-the-badge
[license-url]: https://github.com/clairekc123/flight-prediction/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/linkedin_username
[product-screenshot]: images/screenshot.png
[Next.js]: https://img.shields.io/badge/next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white
[Next-url]: https://nextjs.org/
[React.js]: https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB
[React-url]: https://reactjs.org/
[Vue.js]: https://img.shields.io/badge/Vue.js-35495E?style=for-the-badge&logo=vuedotjs&logoColor=4FC08D
[Vue-url]: https://vuejs.org/
[Angular.io]: https://img.shields.io/badge/Angular-DD0031?style=for-the-badge&logo=angular&logoColor=white
[Angular-url]: https://angular.io/
[Svelte.dev]: https://img.shields.io/badge/Svelte-4A4A55?style=for-the-badge&logo=svelte&logoColor=FF3E00
[Svelte-url]: https://svelte.dev/
[Laravel.com]: https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white
[Laravel-url]: https://laravel.com
[Bootstrap.com]: https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white
[Bootstrap-url]: https://getbootstrap.com
[JQuery.com]: https://img.shields.io/badge/jQuery-0769AD?style=for-the-badge&logo=jquery&logoColor=white
[JQuery-url]: https://jquery.com 
