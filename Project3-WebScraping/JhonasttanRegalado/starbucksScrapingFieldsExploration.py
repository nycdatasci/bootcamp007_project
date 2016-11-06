# -*- coding: utf-8 -*-
"""
Created on Mon Oct 31 17:11:34 2016

@author: jhonasttanregalado
"""
'''
Capture stores

//*[@id="content"]/div[2]/section/div/div[1]/article/a
value: <a class="linkOverlay__primary overlayLink___LjA25" data-e2e="cardLink" href="/store-locator/store/12020/park-row-at-beekman-st-38-park-row-new-york-ny-100381551-us" aria-label="Store details for Park Row at Beekman St"></a>  


Store Details

Store name:
//*[@id="expandedLocationCardLabel"]/span 
value: <h1 class="sb-heading sb-heading--medium pr7 mb1">Park Row at Beekman St</h1>

Address:

Address 1
//*[@id="content"]/div[2]/section/div/div[1]/article/div/div[1]/div[1]/p/span[1] 
value: <span class="addressLine___2afjd">38 Park Row</span>

Address 2
//*[@id="content"]/div[3]/article/div/section[1]/div[2]/div[1]/p/span[2] 
value: <span class="block">#4</span>

City, State, Zip
//*[@id="content"]/div[3]/article/div/section[1]/div[2]/div[1]/p/span[3] 
value: <span class="block">New York, NY 10038</span>

Store Phone Number
//*[@id="content"]/div[3]/article/div/section[1]/div[2]/div[2]/a[1]/div/span 
value: <span>212-608-8073</span>


Ammenities

Parent level
//*[@id="content"]/div[3]/article/div/section[3]/div 
value: <div><h2 class="sb-heading sb-heading--xxsmall font-upper mb3 color-black50"><span>Amenities</span></h2><ul><li class="featureItem___2y-8X"><div class="Arrange"><div class="Arrange-sizeFit"><svg viewBox="0 0 24 24" class="valign-middle icon___2hV4X" preserveAspectRatio="xMidYMid meet" aria-hidden="true" focusable="false" style="width: 20px; height: 20px;"><path d="M13.0855488,13.9416667 C16.8673874,6.98142857 9.99511648,4.125 9.99511648,4.125 C10.9658715,5.29045238 10.8404945,7.46414286 7.95829063,10.325 C2.99086977,16.6327619 11.5326341,19.625 11.5326341,19.625 C10.5428159,16.6888571 12.3464846,15.13 13.0855488,13.9416667 L13.0855488,13.9416667 Z M13.037488,19.6563859 C13.0298004,19.6278299 13.0198064,19.5946432 13.0098125,19.5606846 C12.9882871,19.6409502 13.037488,19.6563859 13.037488,19.6563859 L13.037488,19.6563859 Z M15.6535868,9.78475104 C16.0366632,10.485147 15.2609518,13.5405607 14.1109872,14.875895 C12.2779555,17.1298172 12.8610258,18.7226179 13.056608,19.3677386 C13.0985184,19.2091858 13.4374786,18.7786205 15.1440437,17.6287493 C19.3799426,14.704978 15.6535868,9.78475104 15.6535868,9.78475104 L15.6535868,9.78475104 Z"></path></svg></div><div class="Arrange-sizeFill">Oven-warmed Food</div></div></li><li class="featureItem___2y-8X"><div class="Arrange"><div class="Arrange-sizeFit"><svg viewBox="0 0 24 24" class="valign-middle icon___2hV4X" preserveAspectRatio="xMidYMid meet" aria-hidden="true" focusable="false" style="width: 20px; height: 20px;"><path d="M18.9,9.5c0,0.8-0.6,1.4-1.4,1.4S16,10.3,16,9.5s0.6-1.4,1.4-1.4S18.9,8.7,18.9,9.5z M20,7.9v8.6 c0,0.5-0.4,0.9-0.9,0.9H5C4.5,17.4,4,17,4,16.5V7.9C4,7.4,4.5,7,5,7H19C19.5,7,20,7.4,20,7.9z M15,10.3H4.5v3.9H15V10.3z M19.4,7.9 c0-0.2-0.2-0.4-0.5-0.4h-3.4v9.4h3.4c0.3,0,0.5-0.2,0.5-0.4V7.9z M12.3,13.6h0.5v-1.7h-0.1v-0.5v-0.6h-0.5v0.6V12h0.1V13.6z M11.7,10.8h-0.5v1.7h0.5V10.8z M10.6,11.4h0.5v-0.6h-0.5h-0.5v1.1h0.5V11.4z M14.4,10.8h-1.1v2.8h1.1V10.8z M6.2,10.8H5.1v2.8h1.1 V10.8z M7.3,13H6.8v0.6h0.5V13z M12.2,13.1v-0.6h-0.5v0.6H12.2z M10.5,13.6V13H10v0.6H10.5z M11.1,12.5h-0.5v0.6h0.5v0.5h0.5V13 h-0.5V12.5z M10,11.9H9.5V13H10V11.9z M8.4,11.9v0.6H7.8v0.6h0.6v0.5h0.5h0.5V13H8.9v-0.5V12h0.5v-0.6H8.9v0.5H8.4z M7.8,12h0.5 v-0.6h0.6v-0.6H7.8H7.3v1.7h0.5V12z"></path></svg></div><div class="Arrange-sizeFill">Mobile Payment</div></div></li><li class="featureItem___2y-8X"><div class="Arrange"><div class="Arrange-sizeFit"><svg viewBox="0 0 24 24" class="valign-middle icon___2hV4X" preserveAspectRatio="xMidYMid meet" aria-hidden="true" focusable="false" style="width: 20px; height: 20px;"><path d="M14.5115403,11.2864247 L12.8546187,12.3999017 L13.5630768,14.3571484 L11.9054753,13.2409539 L10.2485537,14.3571484 L10.955652,12.406016 L9.42043292,11.2864247 L11.3187197,11.2864247 L11.9054753,9.61111398 L12.5187471,11.2864247 L14.5115403,11.2864247 L14.5115403,11.2864247 Z M16.9840645,7.02859404 C16.9840645,7.02449891 16.984738,7.03200665 16.9840645,7.02859404 L16.8843807,6.18090115 C16.8762982,6.12356926 16.8156797,6.12834692 16.759776,6.11810908 L16.3105254,6.11810908 L16.0862368,4.52578418 C16.0808485,4.46776977 16.1428141,4.52578418 16.0862368,4.52578418 L7.55451659,4.52578418 C7.4979393,4.52578418 7.5599049,4.46776977 7.55451659,4.52578418 L7.33022806,6.11810908 L6.88097745,6.11810908 C6.82507371,6.12834692 6.76310811,6.13517214 6.75502564,6.19318655 L6.68093633,6.8511382 C6.68093633,6.85523334 6.68160987,6.85455081 6.68160987,6.85864595 L6.65668892,7.02859404 L7.33022806,7.02859404 L8.51094216,19.3563147 C8.51700402,19.4143291 8.56684591,19.5412783 8.6234232,19.5412783 L15.0166567,19.5412783 C15.0739075,19.5412783 15.1224023,19.4143291 15.1284642,19.3563147 L16.3105254,7.02859404 L16.9840645,7.02859404 L16.9840645,7.02859404 Z"></path></svg></div><div class="Arrange-sizeFill">Digital Rewards</div></div></li><li class="featureItem___2y-8X"><div class="Arrange"><div class="Arrange-sizeFit"><svg viewBox="0 0 24 24" class="valign-middle icon___2hV4X" preserveAspectRatio="xMidYMid meet" aria-hidden="true" focusable="false" style="width: 20px; height: 20px;"><path d="M11.1,14.9c0.2,0.2,0.3,0.5,0.3,0.9c0,0.2-0.1,0.6-0.2,1c-0.1,0.4-0.3,0.8-0.3,1c0,0.2,0.2,0.4,0.3,0.7l0,0.3  l-0.8-0.8c-0.5,0.6-1,0.8-1.9,0.8c-0.9,0-1.6-0.3-2.1-0.9c-0.2,0.4-0.5,0.9-0.9,0.9c-0.1,0-0.5,0-1.1,0H4.1v-1.3  c0.5,0,0.9-0.1,1.1-0.4c0.1-0.1,0.3-0.4,0.3-0.8v-3.5c-0.3,0-0.6-0.2-0.6-0.5c0-0.3,0.2-0.6,0.6-0.6v-3c0-0.4-0.1-0.6-0.3-0.8  C5,7.7,4.7,7.6,4.1,7.6V6.3h0.1c0.6,0,1,0.1,1.3,0.2C6,6.5,6.3,6.8,6.4,7.2c0.2-0.3,0.4-0.6,0.7-0.7c0.3-0.1,0.8-0.2,1.4-0.2h0.2  v1.3c-0.5,0-1,0.1-1.2,0.3C7.4,8,7.4,8.3,7.4,8.7v3c0.3,0,0.5,0.3,0.5,0.6c0,0.3-0.2,0.5-0.5,0.5v2.7c0,1.3,0.4,1.9,1.2,1.9  c0.4,0,0.7-0.2,0.9-0.4C9.2,16.6,9,16.2,9,15.8c0-0.4,0.1-0.7,0.3-0.9c0.2-0.2,0.5-0.4,0.9-0.4C10.6,14.5,10.9,14.7,11.1,14.9z   M20,15c0,2.5-1.1,3.7-3.2,3.7c-1.1,0-1.8-0.3-2.2-0.9c-0.1,0.4-0.5,0.9-1,0.9c-0.1,0-0.5,0-1.1,0h-0.3v-1.4c0.5,0,1-0.1,1.2-0.3  c0.1-0.1,0.2-0.4,0.2-0.8v-3.5c-0.3,0-0.4-0.2-0.4-0.5c0-0.3,0.1-0.6,0.4-0.6l0-3c0-0.4,0-0.6-0.2-0.8c-0.2-0.2-0.7-0.3-1.2-0.4V6.3  h0.3c1.2,0,1.9,0.4,2.1,0.9c0.5-0.6,1.2-0.9,2.2-0.9c2.1,0,3.2,1.1,3.2,3.4c0,1.4-0.5,2.3-1.4,2.6C19.5,12.8,20,13.7,20,15z   M15.4,11.7l1,0c1,0,1.5-0.7,1.5-2c0-0.3,0-0.5,0-0.8c0-0.3-0.1-0.5-0.1-0.7s-0.2-0.4-0.4-0.5c-0.2-0.1-0.3-0.1-0.6-0.1  C16,7.6,15.4,8,15.4,9V11.7z M18.1,15c0-1.4-0.7-2.2-1.8-2.2l-0.9,0l0,3.3c0,1,0.5,1.4,1.2,1.4C17.5,17.5,18.1,16.7,18.1,15z"></path></svg></div><div class="Arrange-sizeFill">LaBoulange</div></div></li><li class="featureItem___2y-8X"><div class="Arrange"><div class="Arrange-sizeFit"><svg viewBox="0 0 24 24" class="valign-middle icon___2hV4X" preserveAspectRatio="xMidYMid meet" aria-hidden="true" focusable="false" style="width: 20px; height: 20px;"><path d="M6.561 12.105l1.781 1.742c.911-.893 2.171-1.445 3.562-1.445 1.39 0 2.65.552 3.561 1.445l1.781-1.742c-1.369-1.341-3.259-2.17-5.342-2.17-2.084 0-3.973.829-5.343 2.17zm-3.561-3.487l1.778 1.74c1.823-1.785 4.343-2.891 7.125-2.891s5.302 1.106 7.125 2.891l1.778-1.74c-2.282-2.234-5.43-3.617-8.903-3.617-3.474 0-6.622 1.384-8.903 3.617zm8.372 6.846h-1.509l1.142 1.009-.438 1.426 1.33-.775 1.202.79-.349-1.423 1.193-1.026h-1.539l-.537-1.283-.496 1.283z"></path></svg></div><div class="Arrange-sizeFill">Google Wi-Fi</div></div></li><li class="featureItem___2y-8X"><div class="Arrange"><div class="Arrange-sizeFit"><svg viewBox="0 0 24 24" class="valign-middle icon___2hV4X" preserveAspectRatio="xMidYMid meet" aria-hidden="true" focusable="false" style="width: 20px; height: 20px;"><path d="M12,18l0.2,2H6c-0.5,0-1-0.4-1-1V5c0-0.6,0.4-1,1-1h6.4c0.5,0,1,0.4,1,1v1.9l-0.6,0V6H5.6V18H12z M20,9.6  l-0.4,0L18.4,20l-2.7,0L13,20L11.9,9.6l-0.4,0L11.6,9c0,0,0,0,0-0.1L12,8.8l0.1-1.1v0c0,0,0,0,0,0l7.2,0c0,0,0,0,0,0v0l0.1,1.1  l0.4,0.1c0,0,0,0,0,0.1L20,9.6z M17.6,14c0-1-0.8-1.8-1.8-1.8c-1,0-1.8,0.8-1.8,1.8c0,1,0.8,1.8,1.8,1.8C16.8,15.8,17.6,15,17.6,14z"></path></svg></div><div class="Arrange-sizeFill">Mobile Order and Pay</div></div></li></ul></div>





'''