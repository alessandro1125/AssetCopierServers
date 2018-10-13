<%@ page import="java.net.URISyntaxException" %>
<%@ page import="java.net.URI" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Base64" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.util.GregorianCalendar" %>
<%@ page import="com.assetx.libraries.utils.SqlUtils" %>
<%@ page import="org.assetx.assetcopier.Login" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html lang="it" dir="ltr">
    <head>
        <title>Licence Manager</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" href="/styles" type="text/css">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3mobile.css">
    </head>
    <body class="form-style-8">

        <%

            //Controllo l'action
            int action = 0;
            String message, base64Message;

            try {
                if(request.getParameter("message") != null){
                    try{
                        base64Message = request.getParameter("message");
                        message = new String(Base64.getDecoder().decode(base64Message));
                        //Stampo il message
                        %>
                        <p class="form-style-8"><%= message %></p>
                        <%

                        if (base64Message.equals("VXNlciBkb2Vzbid0IGV4aXN0")){//Login non corretto
                            //Cancello i cookie
                            Cookie[] cookies = request.getCookies();
                            if (cookies != null) {

                                for (int i = 0; i < cookies.length; i++) {
                                    Cookie cookie = cookies[i];
                                    cookies[i].setValue(null);
                                    cookies[i].setMaxAge(0);
                                    response.addCookie(cookie);
                                }
                            }
                        }
                    }catch (NullPointerException e){
                        e.printStackTrace();
                    }
                }
            }catch (Exception e){
                e.printStackTrace();
            }

            try{
                if(request.getParameter("action") != null){
                    try{
                        action = Integer.parseInt(request.getParameter("action"));
                    }catch (NullPointerException e){
                        e.printStackTrace();
                    }
                }
            }catch (Exception e){
                action = 0;
            }


            switch (action){
                case 0:

                    //Controllo i coockies per il login
                    try{
                        Cookie[] cookies = request.getCookies();
                        if (cookies != null) {
                            String email = null;
                            String password = null;
                            String softwareName = null;
                            for (Cookie cookie : cookies) {
                                /*try { TODO resolve not workings cookis
                                    if (cookie.getName().equals("email"))
                                        email = cookie.getValue();
                                    if (cookie.getName().equals("password"))
                                        password = cookie.getValue();
                                    if (cookie.getName().equals("software_name"))
                                        softwareName = cookie.getValue();
                                }catch (NullPointerException e){
                                    e.printStackTrace();
                                }*/
                            }
                            if (email != null && password != null){
                                //Faccio il login
                                authenticationParser(request, response, email, password, softwareName, action);
                            }
                        }
                    }catch (NullPointerException e){
                        e.printStackTrace();
                    }

                    //Mostro il form per il login

                    %>
                <br>
        <div dir="ltr" style="text-align: center;background-color:white;font-family:sans-serif;font-weight:lighter;color:#595959;">
            <div class="form-style-8">
                <h2 id="title_label">assetmax Login</h2>
                <div class="tab">
                    <button class="tablinks" onclick="switchSoftware(event, 'assetmax')">AssetMax</button>
                    <button class="tablinks" onclick="switchSoftware(event, 'assetscalper')">AssetScalper</button>
                </div>
                <br>
                <form action="login?action=1&software_name=assetmax" method="post" id="send_form" enctype="application/x-www-form-urlencoded">
                    <input type="email" name="email" placeholder="Your email..."/>
                    <input type="password" name="password" placeholder="Your password..."/>
                    <input type="submit" value="Login">
                </form>
                <form action="sign_in?action=0&software_name=assetmax" id="sign_in_form" method="post" enctype="application/x-www-form-urlencoded">
                    <input type="submit" value="Sign In">
                </form>
                <form action="sign_in?action=3&software_name=assetmax" id="reset_password_form" method="post" enctype="application/x-www-form-urlencoded">
                    <input type="submit" value="Reset Password">
                </form>
            </div>
        </div>
        <div class = "form-style-8" style="bottom:0;left:20%;">
            Contacts:<blockquote> urimkuci.assetx@gmail.com<br>alessandrogiordano.assetx@gmail.com</blockquote>
        </div>

                    <%
                    break;
                case 1:

                    //FACCIO IL LOGIN

                    String email = null;
                    String password = null;
                    String softwareName = null;

                    try{
                        email = request.getParameter("email");
                        password = Base64.getEncoder().encodeToString(request.getParameter("password").getBytes());
                        softwareName = request.getParameter("software_name");
                    }catch (Exception e){
                        e.printStackTrace();
                    }

                    authenticationParser(request, response, email, password, softwareName, action);
                break;
            }
        %>

        <script>
            function switchSoftware(evt, software_name) {
                document.getElementById("send_form").action = "login?action=1&software_name=" + software_name;
                document.getElementById("sign_in_form").action = "sign_in?action=0&software_name=" + software_name;
                document.getElementById("reset_password_form").action = "sign_in?action=3&software_name=" + software_name;
                //Cambio colore al tema
                if (software_name === "assetmax") {
                    document.documentElement.style.setProperty('--main_color', '#ff4d4d');
                    document.documentElement.style.setProperty('--hover_color', '#ffb3b3');
                }else if(software_name === "assetscalper") {
                    document.documentElement.style.setProperty('--main_color', '#009AB6');
                    document.documentElement.style.setProperty('--hover_color', '#5cadbc');
                }
                var titleLabel = document.getElementById("title_label");
                titleLabel.innerHTML = software_name + " login";
            }
        </script>

        <%!

            /**
             *
             * @param request HttpServletRequest
             * @param response HttpServletResponse
             * @param email String
             * @param action int
             * @param password String
             */
            private static void authenticationParser(HttpServletRequest request, HttpServletResponse response,
                                                     String email, String password, String softwareName, int action){

                try {
                    //Mi connetto al db
                    Connection connection;
                    connection = SqlUtils.getConnectionHeroku();

                    if (connection != null) {
                        if (email != null && password != null && softwareName != null) {

                            //Cerco la corrispondenza nella tabella users

                            switch (Login.authenticateUser(connection, email, password, softwareName)) {
                                case 0:
                                    //Login succesfully done

                                    //Salvo i cookie se action = 1
                                    if (action == 1) {
                                        try {
                                            Cookie emailCk = new Cookie("email", email);
                                            emailCk.setMaxAge(60 * 60 * 24 * 360);
                                            Cookie passwordCk = new Cookie("password", password);
                                            passwordCk.setMaxAge(60 * 60 * 24 * 360);
                                            Cookie softwareCokie = new Cookie("software_name", softwareName);
                                            passwordCk.setMaxAge(60 * 60 * 24 * 360);

                                            response.addCookie(emailCk);
                                            response.addCookie(passwordCk);
                                            response.addCookie(softwareCokie);
                                        } catch (Exception e) {
                                            e.printStackTrace();
                                        }
                                    }

                                    //Se sono autenticato
                                    String dispUrl = null;
                                    try {
                                        dispUrl = request.getParameter("from_page");
                                    }catch (Exception e){
                                        e.printStackTrace();
                                    }
                                    if (dispUrl == null)
                                        dispUrl = "/account_manager?software_name=" + softwareName;
                                    //Controllo dove devo essere reindirizzato
                                    request.setAttribute("email", email);
                                    request.setAttribute("authorization", "authorized");
                                    RequestDispatcher dispatcher;
                                    dispatcher = request.getRequestDispatcher(dispUrl);
                                    dispatcher.forward(request, response);
                                    break;

                                case 1:
                                    //Email Wrong
                                    System.out.println("User email not found");
                                    //Invio un messaggio all'utente
                                    errorOccurred(response, "User doesn't exist");
                                    break;

                                case 2:
                                    //Password wrong
                                    System.out.println("User password not correct");
                                    //Invio un messaggio all'utente
                                    errorOccurred(response, "Password wrong");
                                    break;
                                case 3:
                                    //Software non attivo
                                    System.out.println("Software not activated");
                                    //Invio un messaggio all'utente
                                    errorOccurred(response, "Software not activated");
                                    break;
                                case 4:
                                    //Non attivo
                                    System.out.println("L'utente non è attivo");
                                    //Invio un messaggio all'utente
                                    errorOccurred(response, "User non activated");
                                    break;

                                default:
                                    break;

                            }

                        } else {
                            //Se uno e entrambi i cambi sono nulli
                            System.out.println("Parameters are not valid");
                            //Invio un messaggio all'utente
                            errorOccurred(response, "Enter valids parameters");
                        }

                        try {
                            connection.close();
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }

                    } else {
                        //Se fallisce la connessione al database
                        System.out.println("Unable to connect to database");
                        //Invio un messaggio all'utente
                        errorOccurred(response, "An error has occurred");
                    }
                }catch (Exception e){
                    e.printStackTrace();
                }

            }

            /**
             *
             * @param httpSerletResponse HttpServletResponse
             * @param message String
             */
            private static void errorOccurred(HttpServletResponse httpSerletResponse, String message){
                byte[] messageBy = Base64.getEncoder().encode(message.getBytes());
                String redirectURL = "login?action=0&message=" + new String(messageBy);
                try {
                    httpSerletResponse.sendRedirect(redirectURL);
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        %>
    </body>
</html>
