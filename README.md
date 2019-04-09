# README

Diese Software ist Bestandteil der Bachlorarbeit von Philipp Bzdok (TH Köln, Matr. Nr. 11098952).

## Anleitung (Linux/Mac) ##
1. Ruby 2.5.3 installieren. Vorzugsweise über rbenv (https://github.com/rbenv/rbenv). Details zur Ruby Installation mit rbenv befinden sich auf der GitHub Seite.
2. Wechseln in den Hauptordner des Projektes (```/.../AuthWebApp```). Bundler über Konsole installieren: ```$ gem install bundler -v 1.17.0```.
3. Abhängigkeiten installieren: ```$ bundle install```. Eventuell ist es notwendig Betriebsystem-spezifische SQLite3 Software zu installieren. Der Installationsvorgang von Bundler wird darauf hinweisen.
4. Javascript Runtime installieren, z.B. durch: ```$ sudo apt-get install -y nodejs```.
5. rbenv Umgebung aktualisieren: ```$ rbenv rehash```.
6. Installation prüfen: ```$ rails test```.
7. Datenbank aktualisieren: ```$ rails db:migrate```
7. Server starten: ```$ rails s -b 'ssl://0.0.0.0:3000?key=.ssl/localhost.key&cert=.ssl/localhost.crt'```.
8. Google Chrome öffnen und über ```https://localhost:3000``` auf die Webanwendung zugreifen.