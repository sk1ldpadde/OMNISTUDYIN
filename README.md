![OMNISTUDYIN Logo](./Docs/Images/docs_logo.png)
**"To connect international students and pave the way for meaningful relations online."**

## [About](#about)•[Techstack](#techstack)•[Quickstart](#quickstart)•[C4 Model](#c4-model)•[Contribute](#how-to-contribute)•[Lizenz](#lizenz)•[Sonstiges](#sonstiges)

# 💡 About

OMNISTUDYIN ist eine Social Media Handy-Applikation, die darauf abzielt, die Studenten unserer Welt zu verknüpfen.

Sie bietet die Folgenden Hauptfunktionalitäten:

- Ein Reddit-like "Posts"-System mit dem Erstellen und Anzeigen von Posts und Postgroups, sowie die Suche danach
- Ein Freundschaftssystem mit täglich neuen Freundschafts-Vorschlägen, basierend auf angegebenen Interessen/Zielen, für das internationalen Verknüpfen mit neuen Menschen
- Ein Chatsystem zum Interagieren mit anderen Menschen

# 👨‍💻 Techstack

Eine kurze highlevel-Beschreibung der benutzten Technologien in diesem Projekt

- Dieses Projekt benutzt das [Flutter-Framework](https://docs.flutter.dev/) für das Entwickeln von Cross-Plattform Apps (Android, IOS, Web) als Frontend.
- Für die persistente Datenbank wurde [Neo4j](https://neo4j.com/) ausgewählt. Diese NoSQL - Graph - Datenbank liefert eine übersichtliche Graphstruktur, welche Entititäten mittels Knoten darstellt und Beziehungen durch Kanten zwischen den Knoten abstrahiert. Somit ergibt sich ein übersichtliches Netzwerk innerhalb der Datenbank, die so **fast 1:1 die Social-media-Application wiederspiegelt**.
- Die Schnittstelle zwischen Flutter-Frontend und der Neo4j-Datenbank bildet das Python-Framework [Django](https://www.djangoproject.com/). Django unterstützt Neo4j nicht out-of-the-Box, deswegen wurde die [NeoModel](https://neomodel.readthedocs.io/en/latest/) Bibliothek benutzt.
- Das Django-Backend und die Datenbank wurde für eine übersichtliche und unkomplizierte Entwichlung mittels [Docker](https://docs.docker.com/) in unabhängige Container virtualisiert. Das Frontend wurde aufgrund der Benutzung von Offline-Handy-Emulatoren nicht zusätzlich virtualisiert.

# 🛫 Quickstart

Folge diesen Schritten, um mit OMNISTUDYIN schnell auszuführen:

### Git Repository klonen

Klone das Repository, indem der folgende Befehl in der Kommandozeile oder im Terminal ausgeführt wird:

    git clone https://github.com/sk1ldpadde/OMNISTUDYIN.git

### Flutter installieren

Installiere Flutter gemäß der [offiziellen Flutter-Dokumentation](https://flutter.dev/docs/get-started/install).

### Docker Desktop installieren

Installiere Docker Desktop nach der Anleitung auf der [offiziellen Docker-Website](https://docs.docker.com/desktop/). Erstelle anschließend einen Account und starte die Anwendung.

### Setup-Skript ausführen

Navigiere in das geklonte Verzeichnis und führe die entsprechende Setup-Datei aus:

- Für Windows:

  ```
  .\SETUP.bat
  ```

- Für Linux/Mac:
  ```
  ./SETUP.sh
  ```

### Flutter Applikation starten

Wechsle in den Ordner `omnistudin_flutter` und führe den Befehl aus:

    flutter run

Nach diesen Schritten sollte die OMNISTUDYIN-App lauffähig sein.

# 🧨 C4 Model

Dies ist das C4 Modell für das Projekt.
Für eine schönere Ansicht: Lightmode aktivieren!

#### [System Context Diagram](#system-context-diagram)•[Container Diagram](#container-diagram)•[Component Diagram](#component-diagram)

### System Context Diagram

```mermaid
C4Context
    title System Context diagram for OMNISTUDYIN
    Person(student1,"german student", "A student from Germany")
    Person(student2, "japanese student", "A student from Japan")
    System(omnistudyin, "OMNISTUDYIN", "A social media app for bringing together international students")
    Rel(student1, omnistudyin, "uses", "Via IOS")
    Rel(student2, omnistudyin, "uses", "Via Android")
```

### Container diagram

```mermaid
C4Context
     title Container diagram for OMNISTUDYIN
    Person(student1,"german student", "A student from Germany")
    Person(student2, "japanese student", "A student from Japan")
System_Boundary(c1, "OMNISTUDYIN") {
    Container(flutter, "Flutter Frontend", "Dart MVC", "Allows users to use the App in all funtionalities")
    Container(django,"Django Backend", "Python ORM", "Serves the APIs for the database-models")
    Container(neo4j, "Neo4j Datbase", "Graph database", "Serves all of the models like postgroups, posts, friends, chats")
}


    Rel(student1, flutter, "uses", "Via IOS")
    Rel(student2, flutter, "uses", "Via Android")

    Rel(flutter, django, "get/post/put/delete -requests", "sends HTTP-Requests for data")
    BiRel(django, neo4j, "exchange data")

```

### Component diagram

```mermaid
C4Context
     title Component diagram for OMNISTUDYIN

System_Boundary(c1, "OMNISTUDYIN") {
    Container_Boundary(flutter, "Flutter Frontend"){

    Component(landingpage,"Landingpage", "Create Account / Login","Create Account and Login")
    Component(homepage,"Homepage", "Postgroups & posts","Display, add, edit and search for postgroups/posts")
    Component(friendspage,"Friendspage", "Friends & suggestions","Display, add and accept friends. Get friend-suggestions")
    Component(chatpage,"Chatspage", "Chat between Friends","Display groups, get into chats and write / read messages")

    }

    Container_Boundary(django,"Django Backend"){

    Component(postsapi,"Posts/Postgroups-API", "postgroups & posts","get, add, change delete and search postgroups/posts")
    Component(studentsapi,"Students-API", "Accountmanagement","create an account, login, get JWT TOken for sessions, get profile information")
    Component(friendsapi, "Friends-API", "Friends-functionality", "send friendrequests, accept friendrequests, get the friends of a Student, get friend suggestions")

    }


    Container_Boundary(neo4j,"neo4j Database"){

    Component(student,"Student-Model", "Accountmanagement Model")
    Component(postgroup,"Postgroup-Model")
    Component(post,"Post-Model")

    }

    BiRel(landingpage, postsapi, "displays, add, change, deletes, searches in")
    BiRel(homepage, studentsapi, "creates / Login")
    BiRel(friendspage, friendsapi, "gets, adds, accepts via")

    BiRel(postsapi, post, "neomodel-use")
    BiRel(postsapi, postgroup, "neomodel-use")
    BiRel(studentsapi, student, "neomodel-use")
    BiRel(friendsapi, student, "neomodel-use")

}
```

# 🙏 How to contribute

Hier sind einige Richtlinien, wie man zum Projekt beitragen kann:

### Schritte zum Mitwirken

1. **Fork das Repository**  
   Beginne damit, das Projekt zu forken und dann deine Kopie lokal zu klonen.

2. **Erstelle einen neuen Branch**  
   Erstelle einen neuen Branch für jede Verbesserung oder Korrektur, z.B. `git checkout -b feature/meine-neue-funktion` oder `git checkout -b fix/bugfix`.

3. **Mache deine Änderungen**  
   Führe die Änderungen durch, die du für wichtig hältst. Stelle sicher, dass du deinen Code testest und dass er den bestehenden Richtlinien entspricht.

4. **Commit deine Änderungen**  
   Füge deine Änderungen mit `git add .` hinzu und erstelle einen Commit mit `git commit -m 'Füge eine nützliche Nachricht hinzu'`. Die Commit-Nachricht sollte klar und aussagekräftig sein.

5. **Push deinen Branch**  
   Lade deine Änderungen mit `git push origin feature/meine-neue-funktion` hoch.

6. **Erstelle einen Pull Request**  
   Gehe auf GitHub zu dem ursprünglichen Repository und erstelle einen Pull Request von deinem Fork. Beschreibe im Pull Request deine Änderungen und warum sie wichtig sind.

## Richtlinien

- Stelle sicher, dass dein Code den Stil- und Qualitätsstandards entspricht.
- Füge Tests hinzu, wenn du neue Funktionen implementierst.
- Aktualisiere die Dokumentation, wenn du Änderungen an der Funktionalität vornimmst.
- Verwende aussagekräftige Commit-Nachrichten.

Wir freuen uns auf alle Beiträge!

# ⚠️ Lizenz

Dieses Projekt ist unter der MIT-Lizenz lizenziert. Diese Lizenz ermöglicht es jedem, die Software für private oder kommerzielle Zwecke frei zu nutzen, zu verändern, zu verbreiten und zu verkaufen. Die MIT-Lizenz ist eine der permissivsten Lizenzen und legt nur sehr wenige Einschränkungen fest. Dabei muss lediglich der Urheberrechtshinweis und die Lizenzinformation in allen Kopien oder wesentlichen Teilen der Software erhalten bleiben.

Die vollständige Lizenztext der MIT-Lizenz kann [hier](https://opensource.org/licenses/MIT) eingesehen werden. Durch die Nutzung dieses Projekts stimmen Sie den Bedingungen der MIT-Lizenz zu.

Wir haben uns für die MIT-Lizenz entschieden, um die Nutzung und Weiterentwicklung der Software so offen und unkompliziert wie möglich zu gestalten. Wir ermutigen alle Nutzer, aktiv zur Verbesserung beizutragen und ihre Modifikationen mit der Gemeinschaft zu teilen.

# Sonstiges

## Overview

- [Sonstiges](#sonstiges)
  - [Retrospective](#retrospective)
  - [Where to find what](#where-to-find-what)
    - [Backend:](#backend)
      - [Views](#views)
      - [Backend-Algorithmen](#backend-algorithmen)
      - [Django](#django)
  - [Komplexere Algorithmen](#komplexere-algorithmen)
    - [Chat-System](#chat-system)
    -

## Retrospective

|                            ☀️                             |                            ☁️                            |           🔜            |
|:---------------------------------------------------------:|:--------------------------------------------------------:| :---------------------: |
|      Implementierung von neo4j hat sehr gut geklappt      |           Frontend wurde zu langsam aufgebaut            | Mehr Frontend developer |
| Flutter lässt sich mittels Copilot sehr schnell schreiben |           Flutter an sich ist unnötig komplex            |   Mehr Dokumentation         |
|       Strukturierung des Teams verlief hervorragend       | Umstellung Linux/Mac für Backend Funktionalität stressig |           Mehr Code Kommentare            |
|      Docker Einrichtung verlief ebenso reibungslos        |        Flutter Code wird schnell unübersichtlich         ||

## Where to find what

### Backend:

Der Ordner data_logic ist der Haupt-Ordner für die Backendlogik.
Hier findet man:

#### Views

In dem Ordner "views": Alle Algorithmen, die sich direkt mit API-Access beschäftigt

- Ad_Group: Get all groups, Creation, Deletion
- Ad: Get, Creation, Deletion, Changing of a ad in a adgroup --> Ein Ad muss eine parent-adgroup haben
- Students: Accountservice - Registering, Login (mit sessiontokens: JWT), sessiontoken-Updating, Change/Deletion von Accounts.
- Friends: Senden/Annehmen von Freundschaftsanfragen, Get all students, **find-friends-Algorithmus-view**
- Chat: Send-Chat-Message, Pull-Chat-Message

#### Backend-Algorithmen

Die meisten Backend-Algorithmen kann man in der Datei util.py finden.
Hier findet man:

- Algo, der das Alter eines Studenten berechnet
- Hashed passwort Vergleiche
- Profanity Check: Text nach Beleidigungen etc scannen
- Alle Sachen rund um SessionTokens: Java Web Tokens: Creation & Decoding von JWTs

#### Django

Der Omnistudyin_Backend-Ordner besitzt prinzipiell nur django-spezifische Inhalte.

- urls.py ist hier am wichtigsten, als Aufzählung der API-Points

## Komplexere Algorithmen

### Chat-System

**TODO: DHBWKNK**
