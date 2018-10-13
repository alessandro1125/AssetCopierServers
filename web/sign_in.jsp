<%@ page import="javax.mail.*" %>
<%@ page import="javax.mail.internet.*" %>
<%@ page import="java.net.URI" %>
<%@ page import="java.net.URISyntaxException" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="com.assetx.libraries.utils.SqlUtils" %>
<%@ page import="org.assetx.assetcopier.Login" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
    <head>
        <title>AssetCopier Sign In</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href="/styles" rel="stylesheet" type="text/css">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3mobile.css">
    </head>
    <body dir="ltr" dir="ltr" style="text-align: center;background-color:white;font-family:sans-serif;font-weight:lighter;color:#595959;">

        <%!
            private static final String ERROR_CODE_PAGE = "100";
        %>

        <%

            //Scarico il parametro di azione da svolgere
            int action = 0;
            try {
                if(request.getParameter("action") != null)
                    action = Integer.parseInt(request.getParameter("action"));
            }catch (NumberFormatException e){
                e.printStackTrace();
                action = 0;
            }catch (NullPointerException e){
                e.printStackTrace();
            }

            switch (action){

                case 0:
                    //Mostro il form per la registrazione
                    %>

        <br>
        <div class="form-style-8">
            <h2>AssetCopier Sign In</h2>
            <p id="reportMessage" style="display: none"></p>
            <form action="sign_in?action=1" method="post" enctype="application/x-www-form-urlencoded">
                <input type="text" id="nome" name="nome" placeholder="Name...">
                <input type="email" id="email" name="email" placeholder="Email..." style="display: none">
                <input type="password" id="password" name="password" placeholder="Password..." style="display: none">
                <input type="password" id="password_rep" placeholder="Repeat password..." style="display: none">

                <input type="submit" id="submit" style="display: none" value="Sing In">
            </form>
            <input type="submit" id="next" value="Next" onclick="next()">
        </div>

        <div class = "form-style-8" style="bottom:0px;left:20%;">
            Contacts:<blockquote> alessandrogiordano@assetcopier.com</blockquote>
        </div>
        <script type="application/javascript">

            var state = 0;

            document.getElementById("submit").type = "text";//Disattivo la funzione del submit

            function next() {
                switch (state){

                    case 0:
                        //Controllo che il campo nome non sia vuoto
                        if (document.getElementById("nome").value.localeCompare("") !== 0){
                            document.getElementById("nome").style.display = "none";
                            document.getElementById("email").style.display = "block";
                            document.getElementById("reportMessage").style.display = "none";//Nascodo il messaggio

                            state++;
                        }else {
                            document.getElementById("reportMessage").style.display = "block";
                            document.getElementById("reportMessage").innerHTML = "Enter a valid value for Name";//Mostro il messaggio
                            document.getElementById("nome").value = "";
                        }
                        break;

                    case 1:
                        if (document.getElementById("email").value.localeCompare("") !== 0 &&
                                (document.getElementById("email").value.search("@") !== -1)){
                            document.getElementById("email").style.display = "none";
                            document.getElementById("password").style.display = "block";
                            document.getElementById("password_rep").style.display = "block";
                            document.getElementById("reportMessage").style.display = "none";//Nascodo il messaggio

                            state++;
                        }else {
                            document.getElementById("reportMessage").style.display = "block";
                            document.getElementById("reportMessage").innerHTML = "Enter a valid email value";//Mostro il messaggio
                            document.getElementById("email").value = "";
                        }
                        break;

                    case 2:
                        if (document.getElementById("password").value.length >=8){
                            //Confronto le 2 password
                            if(document.getElementById("password").value.localeCompare
                                (document.getElementById("password_rep").value) === 0){
                                document.getElementById("password").style.display = "none";
                                document.getElementById("password_rep").style.display = "none";
                                document.getElementById("reportMessage").style.display = "none";//Nascodo il messaggio

                                //Mostro i pulsanti
                                document.getElementById("next").style.display = "none";
                                document.getElementById("submit").type = "submit";//TODO remove con controllo errori
                                document.getElementById("submit").style.display = "block";
                            }else {
                                document.getElementById("reportMessage").style.display = "block";
                                document.getElementById("reportMessage").innerHTML = "Passwords must be the same";//Mostro il messaggio
                                document.getElementById("password").value = "";
                                document.getElementById("password_rep").value = "";
                            }
                        }else {
                            document.getElementById("reportMessage").style.display = "block";
                            document.getElementById("reportMessage").innerHTML = "Password minimum size must be 8";//Mostro il messaggio
                            document.getElementById("password").value = "";
                            document.getElementById("password_rep").value = "";
                        }
                        break;

                    default:
                        state = 0;
                        break;
                }
            }
        </script>

                    <%
                    break;
                case 1:
                    //Registro l'account e invio l'email di conferma

                    //Scarico i parametri dell'account
                    String email = null;
                    String password = null;
                    String softwareName = null;
                    String name = null;
                    try{
                        email = Base64.getEncoder().encodeToString(request.getParameter("email").getBytes());
                        password = Base64.getEncoder().encodeToString(request.getParameter("password").getBytes());
                        name = Base64.getEncoder().encodeToString(request.getParameter("nome").getBytes());
                    }catch (NullPointerException e){;
                        e.printStackTrace();
                        String redirectURL = "login?action=0&message=" +
                                new String(Base64.getEncoder().encode(("An error has occurred " +
                                        ERROR_CODE_PAGE + "x01").getBytes()));
                        response.sendRedirect(redirectURL);
                    }catch (NumberFormatException e){
                        e.printStackTrace();
                    }

                    double passkeyDoub = (Math.floor(Math.random() * Math.pow(10, 16)) / Math.pow(10, 16));
                    String passkey = Double.toString(passkeyDoub).substring(2);

                    String passkeyUrlEncoded = URLEncoder.encode(new String(Base64.getEncoder().encode(passkey.getBytes())), "UTF-8");
                    String emailUrlEncoded = URLEncoder.encode(email, "UTF-8");
                    String text = "To confirm your Get Advertisment Account click to the following link: " +
                            "https://assetmax.herokuapp.com/sign_in?action=2&passkey=" + passkeyUrlEncoded
                            + "&email=" + emailUrlEncoded;
                    if(sendEmail(new String(Base64.getDecoder().decode(email.getBytes())), text, "User confirmation")){

                        //Se l'email è stata inviata correttamente salvo l'utente nel database
                        HashMap<String, Object> map = new HashMap();
                        map.put("email", email);
                        map.put("password", password);
                        map.put("name", name);
                        map.put("surname", name);
                        map.put("passkey", passkey);
                        map.put("email_active", 0);
                        map.put("licence_active", 0);
                        map.put("account_id", "0");
                        map.put("chat_id", "00");
                        map.put("trades_listen", false);

                        Connection connection = null;

                        try {
                            connection = SqlUtils.getConnectionHeroku();
                        }catch (Exception e){
                            e.printStackTrace();
                            System.out.println("Errore nella connessione con il batabase " + ERROR_CODE_PAGE + "x02");
                            String redirectURL = "login?action=0&message=" +
                                    new String(Base64.getEncoder().encode(("An error has occurred " +
                                            ERROR_CODE_PAGE + "x02").getBytes()));
                            response.sendRedirect(redirectURL);
                        }

                        //Controllo se l'utente è già registrato
                        try{
                        if(Login.authenticateUser(null, email, "") == 1){

                            if(SqlUtils.sqlAdd(connection , map, "users")){

                                //Stampo la risposta
                                %>
                <br>
                <div class="form-style-8">
                    <h2>Ceck your email box to confirm your account</h2>
                </div>
                                <%
                            }else {
                                try {
                                    connection.close();
                                } catch (SQLException e1) {
                                    e1.printStackTrace();
                                }
                                System.out.println("Errore nella scrittura nel database "+ ERROR_CODE_PAGE + "x03");
                                String redirectURL = "login?action=0&message=" +
                                        new String(Base64.getEncoder().encode(("An error has occurred " +
                                                ERROR_CODE_PAGE + "x03").getBytes()));
                                response.sendRedirect(redirectURL);
                            }
                        }else {
                            System.out.println("L'utente è già registrato");
                                try {
                                    connection.close();
                                } catch (SQLException e1) {
                                    e1.printStackTrace();
                                }
                            String redirectURL = "login?action=0&message=" +
                                    new String(Base64.getEncoder().encode(("User already registered".getBytes())));
                            response.sendRedirect(redirectURL);
                        }
                                            }catch (SQLException e) {
                            e.printStackTrace();
                            }
                        try {
                            connection.close();
                        } catch (SQLException e1) {
                            e1.printStackTrace();
                        }
                    }else {
                        System.out.println("Errore nell'invio dell'email di conferma " + ERROR_CODE_PAGE + "x04");
                        String redirectURL = "login?action=0&message=" +
                                new String(Base64.getEncoder().encode(("An error has occurred " +
                                        ERROR_CODE_PAGE + "x04").getBytes()));
                        response.sendRedirect(redirectURL);
                    }

                    break;
                case 2:
                    //Eseguo l'attivazione dell'account
                    String passkey2 = null;
                    String email2 = null;
                    try {
                        passkey2 =  URLDecoder.decode(request.getParameter("passkey"), "UTF-8");
                        email2 =    Base64.getEncoder().encodeToString(URLDecoder.decode(request.getParameter("email"), "UTF-8").getBytes());
                    }catch (NullPointerException e){
                        e.printStackTrace();
                        System.out.println("Errore nella recezione della passkey " + ERROR_CODE_PAGE + "x05");
                        String redirectURL = "login?action=0&message=" +
                                new String(Base64.getEncoder().encode(("An error has occurred " +
                                        ERROR_CODE_PAGE + "x05").getBytes()));
                        response.sendRedirect(redirectURL);
                    }catch (NumberFormatException e){
                        e.printStackTrace();
                    }

                    //Controllo se la passkey è corretta
                    Connection connection = SqlUtils.getConnectionHeroku();
                    if (checkPasskey(connection, passkey2, email2)){
                        //Aggiorno lo stato di attivazione e cancello la passkey
                        if(updateActivtion(connection, email2)) {
                            try {
                                connection.close();
                            } catch (SQLException e1) {
                                e1.printStackTrace();
                            }
                            String redirectURL = "login?action=0&message=" +
                                    new String(Base64.getEncoder().encode("User Correctly activated".getBytes()));
                            response.sendRedirect(redirectURL);
                        }else {
                            try {
                                connection.close();
                            } catch (SQLException e1) {
                                e1.printStackTrace();
                            }
                            System.out.println("Errore nell'aggiornamento del database " + ERROR_CODE_PAGE + "x07");
                            String redirectURL = "login?action=0&message=" +
                                    new String(Base64.getEncoder().encode(("An error has occurred " +
                                            ERROR_CODE_PAGE + "x07").getBytes()));
                            response.sendRedirect(redirectURL);
                        }
                    }else {
                        try {
                            connection.close();
                        } catch (SQLException e1) {
                            e1.printStackTrace();
                        }
                        System.out.println("Errore nell'attivazione della passkey " + ERROR_CODE_PAGE + "x06");
                        String redirectURL = "login?action=0&message=" +
                                new String(Base64.getEncoder().encode(("An error has occurred " +
                                        ERROR_CODE_PAGE + "x06").getBytes()));
                        response.sendRedirect(redirectURL);
                    }


                    break;

                case 3:

                    //Richiesta di resettare la password
                    //Mostro il form per l'interimento dell'email

                    %>
        <div class="form-style-8">
            <h2>Reset Password</h2>
            <form class="form-style-8" action="sign_in?action=4" method="POST" enctype="application/x-www-form-urlencoded">
                <input type="email" name="email" placeholder="Enter your email...">
                <input type="submit" value="Submit">
            </form>
        </div>
                    <%
                    break;

                case 4:
                    String email4 = null;
                    try{
                        email4 = new String(Base64.getEncoder().encode(request.getParameter("email").getBytes()));
                    }catch (NullPointerException e){
                        e.printStackTrace();
                        System.out.println("Errore nel parametro " + ERROR_CODE_PAGE + "x08");
                        String redirectURL = "login?action=0&message=" +
                                new String(Base64.getEncoder().encode(("An error has occurred " +
                                        ERROR_CODE_PAGE + "x08").getBytes()));
                        response.sendRedirect(redirectURL);
                    }catch (NumberFormatException e){
                        e.printStackTrace();
                    }

                    //Controllo se l'utente è già stato attivato
                    Connection connectionPass = SqlUtils.getConnectionHeroku();
                    if(searchUserAtivated(connectionPass, email4)){
                        //Genero la passkey per la modifica password
                        double passkeyPassDoub = (Math.floor(Math.random() * Math.pow(10, 16)) / Math.pow(10, 16));
                        String passkeyPass = Double.toString(passkeyPassDoub).substring(2,Double.toString(passkeyPassDoub).length());

                        //Invio la passkey per email
                        String textPass = "To change your password please click on this link: " +
                                "https://assetcopiernode.herokuapp.com/sign_in?action=5&email="+
                                URLEncoder.encode(new String(Base64.getEncoder().encode(email4.getBytes())),"UTF-8")
                                + "&passkey=" +URLEncoder.encode(new String(Base64.getEncoder().encode(passkeyPass.getBytes())),"UTF-8");
                        if(sendEmail(new String(Base64.getDecoder().decode(email4.getBytes())), textPass, "Reset password")){
                            //Aggiorno il database
                            if (updatePasskey(connectionPass, email4, passkeyPass)){
                                //Stampo la risposta
                                try {
                                    connectionPass.close();
                                } catch (SQLException e) {
                                    e.printStackTrace();
                                }
                                %>
        <br>
        <div class="form-style-8">
            <h2>Ceck your email box to reset your password</h2>
        </div>
                                <%
                            }else {
                                try {
                                    connectionPass.close();
                                } catch (SQLException e) {
                                    e.printStackTrace();
                                }
                                System.out.println("Errore nell'aggiornamento del database" + ERROR_CODE_PAGE + "x10");
                                String redirectURL = "login?action=0&message=" +
                                        new String(Base64.getEncoder().encode(("An error has occurred " +
                                                ERROR_CODE_PAGE + "x10").getBytes()));
                                response.sendRedirect(redirectURL);
                            }

                        }else {
                            try {
                                connectionPass.close();
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
                            System.out.println("Errore nell'invio dell'email" + ERROR_CODE_PAGE + "x09");
                            String redirectURL = "login?action=0&message=" +
                                    new String(Base64.getEncoder().encode(("Cannot send Email " +
                                            ERROR_CODE_PAGE + "x09").getBytes()));
                            response.sendRedirect(redirectURL);
                        }
                    }else {
                        try {
                            connectionPass.close();
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                        String redirectURL = "login?action=0&message=" +
                                new String(Base64.getEncoder().encode(("User is not activated").getBytes()));
                        response.sendRedirect(redirectURL);
                    }



                    break;

                case 5:
                    //Reimposto la password

                    //Scarico e decodifico i parametri url (BASE64 e URL)
                    String email5 = null;
                    String passkey5 = null;
                    String email5Encoded = null;
                    try{
                        email5Encoded = request.getParameter("email");
                        email5 =    new String(Base64.getDecoder().decode(URLDecoder.decode(email5Encoded, "UTF-8").getBytes()));
                        passkey5 =  new String(Base64.getDecoder().decode(URLDecoder.decode
                                (request.getParameter("passkey"), "UTF-8").getBytes()));
                    }catch (NullPointerException e){
                        e.printStackTrace();
                        System.out.println("Error: " + ERROR_CODE_PAGE + "x11");
                        String redirectURL = "login?action=0&message=" +
                                new String(Base64.getEncoder().encode(("An error has occurred"  +
                                        ERROR_CODE_PAGE + "x11").getBytes()));
                        response.sendRedirect(redirectURL);
                    }catch (NumberFormatException e){
                        e.printStackTrace();
                    }

                    //Controllo nel database se i dati corrispondono
                    Connection connection5 = SqlUtils.getConnectionHeroku();
                    if (checkPasskey(connection5, passkey5, email5)){
                        //Mostro il form per la reimpostazione della password
                        %>
        <div class="form-style-8">
            <h2>Set new password</h2>
            <p id="messagesp" style="display: none"></p>
            <form class="form-style-8" action="sign_in?action=6&email=<%= email5Encoded%>" method="POST" enctype="application/x-www-form-urlencoded">
                <input type="password" id="newpassword" name="password" placeholder="Enter the new password...">
                <input type="password" id="newpasswordconf" name="password_confirm" placeholder="Confirm password...">
                <input type="submit" value="Confirm" id="sendreq" style="display: none">
            </form>
            <input type="submit" value="Submit" id="check" onclick="check_password()">

            <script type="application/javascript">
                function check_password() {
                    if (document.getElementById("newpassword").value.length >= 8){
                        if(document.getElementById("newpassword").value.localeCompare(document.getElementById
                            ("newpasswordconf").value) === 0){
                            //Cambio la password
                            document.getElementById("newpassword").style.display = "none";
                            document.getElementById("newpasswordconf").style.display = "none";
                            document.getElementById("messagesp").innerHTML = "Ckick confirm to update your password";
                            document.getElementById("messagesp").style.display = "block";

                            document.getElementById("sendreq").style.display = "block";
                            document.getElementById("check").style.display = "none";

                        }else {
                            document.getElementById("messagesp").innerHTML = "Passwords must be the same";
                            document.getElementById("messagesp").style.display = "block";
                        }
                    }else {
                        document.getElementById("messagesp").innerHTML = "Minimum password size must be 8";
                        document.getElementById("messagesp").style.display = "block";
                        document.getElementById("newpassword").value = "";
                        document.getElementById("newpasswordconf").value = "";
                    }
                }

            </script>
        </div>
                        <%
                        try {
                            connection5.close();
                        }catch (SQLException e){
                            e.printStackTrace();
                        }
                    }else {
                        //Controllo passkey non riuscito
                        try {
                            connection5.close();
                        }catch (SQLException e){
                            e.printStackTrace();
                        }
                        String redirectURL = "login?action=0&message=" +
                                new String(Base64.getEncoder().encode(("An error has occurred "+
                                        ERROR_CODE_PAGE + "x12").getBytes()));
                        response.sendRedirect(redirectURL);
                    }



                    break;

                case 6:
                    String email6 = null;
                    String newPassword = null;

                    //Decodifico email e password e inserisco la password nel db
                    try{
                        email6 = new String(Base64.getDecoder().decode(URLDecoder.decode
                                (request.getParameter("email"), "UTF-8")));
                        newPassword = request.getParameter("password");
                    }catch (NullPointerException e){
                        e.printStackTrace();
                        String redirectURL = "login?action=0&message=" +
                                new String(Base64.getEncoder().encode(("An error has occurred "+
                                        ERROR_CODE_PAGE + "x13").getBytes()));
                        response.sendRedirect(redirectURL);
                    }catch (NumberFormatException e){
                        e.printStackTrace();
                        String redirectURL = "login?action=0&message=" +
                                new String(Base64.getEncoder().encode(("An error has occurred "+
                                        ERROR_CODE_PAGE + "x14").getBytes()));
                        response.sendRedirect(redirectURL);
                    }
                    System.out.println(email6);
                    System.out.print(newPassword);

                    //Aggiorno il db
                    Connection connection6 = SqlUtils.getConnectionHeroku();
                    if(updatePassword(connection6, email6, newPassword)){
                        try {
                            connection6.close();
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                        String redirectURL = "login?action=0&message=" +
                                new String(Base64.getEncoder().encode(("Passsword succesfully changed").getBytes()));
                        response.sendRedirect(redirectURL);
                    }else {
                        try {
                            connection6.close();
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                        String redirectURL = "login?action=0&message=" +
                                new String(Base64.getEncoder().encode(("An error has occurred "+
                                        ERROR_CODE_PAGE + "x15").getBytes()));
                        response.sendRedirect(redirectURL);
                    }
                    break;

                default:
                    response.sendRedirect("login?action=0");
                    break;
            }


        %>

        <%!

            /**
             *
             * @param connection Connection
             * @param email String
             * @param password String
             * @return boolean
             */
            private static boolean updatePassword(Connection connection, String email, String password){

                Statement stmt;
                String query = "UPDATE users SET passkey='0',password='" + password + "' WHERE email='" + email + "'";

                try {
                    stmt = connection.createStatement();
                    stmt.executeUpdate(query);
                    stmt.close();
                    return true;
                }catch (SQLException e) {
                    e.printStackTrace();
                    System.out.println(e.toString());
                    return false;
                }
            }

            /**
             *
             * @param connection Connection
             * @param email String
             * @param passkey String
             * @return boolean
             */
            private static boolean updatePasskey(Connection connection, String email, String passkey){

                Statement stmt;
                String query = "UPDATE users SET passkey='" + passkey + "' WHERE email='" + email + "'";

                try {
                    stmt = connection.createStatement();
                    stmt.executeUpdate(query);
                    stmt.close();
                    return true;
                }catch (SQLException e) {
                    e.printStackTrace();
                    System.out.println(e.toString());
                    return false;
                }
            }

            /**
             *
             * @param connection Connection
             * @param email String
             * @return boolean
             */
            private static boolean updateActivtion(Connection connection, String email){

                Statement stmt;
                String query = "UPDATE users SET email_active='1', passkey='0' WHERE email='" + email + "'";

                try {
                    stmt = connection.createStatement();
                    stmt.executeUpdate(query);
                    stmt.close();
                    return true;
                }catch (SQLException e) {
                    e.printStackTrace();
                    System.out.println(e.toString());
                    return false;
                }
            }

            /**
             *
             * @param connection Connection
             * @param passKey String
             * @param email String
             * @return boolean
             */
            private static boolean checkPasskey(Connection connection, String passKey, String email){

                //Faccio una chiamata al db
                Statement statement;
                String query;

                query = "SELECT passkey FROM users WHERE email='" + email +"'";

                try{
                    statement = connection.createStatement();
                    ResultSet resultSet = statement.executeQuery(query);

                    if (resultSet != null){
                        while (resultSet.next()){
                            //Controllo corrispondenze
                            if ((resultSet.getString("passkey").equals(passKey)))
                                return true;
                        }
                    }else {
                        System.out.println("Empity resultset");
                    }
                    return false;
                }catch (Exception sqle){
                    System.out.println(sqle.toString());
                    sqle.printStackTrace();
                    return false;
                }
            }

            /**
             *
             * @param connection Connection
             * @param email String
             * @return boolean
             */
            private static boolean searchUserAtivated(Connection connection, String email){

                //Faccio una chiamata al db
                Statement statement;
                String query;

                query = "SELECT email,email_active FROM users";

                try{
                    statement = connection.createStatement();
                    ResultSet resultSet = statement.executeQuery(query);

                    while (resultSet.next()){
                        //Controllo corrispondenze
                        if (resultSet.getString("email").equals(email) &&
                                resultSet.getString("email_active").equals("1"))
                            return true;
                    }
                    return false;
                }catch (SQLException sqle){
                    sqle.printStackTrace();
                    return false;
                }
            }

            /**
             *
             * @param email String
             * @param text String
             * @param object String
             * @return boolean
             */
            private static boolean sendEmail(String email, String text, String object){

                // Sender's email ID needs to be mentioned
                String from = "AssetCopier";

                // Assuming you are sending email from localhost
                String host = "smtp.gmail.com";

                // Get system properties
                Properties properties = System.getProperties();

                // Setup mail server
                properties.setProperty("mail.smtp.host", host);

                properties.put("mail.smtp.starttls.enable", "true");
                properties.put("mail.smtp.port", "587");

                // Get the default Session object.
                Session session = Session.getDefaultInstance(properties);

                try {
                    // Create a default MimeMessage object.
                    MimeMessage message = new MimeMessage(session);

                    // Set From: header field of the header.
                    message.setFrom(new InternetAddress(from));

                    // Set To: header field of the header.
                    message.addRecipient(Message.RecipientType.TO, new InternetAddress(email));

                    // Set Subject: header field
                    message.setSubject(object);

                    // Now set the actual message
                    message.setText(text);

                    // Send message
                    Transport transport = session.getTransport("smtp");
                    transport.connect("alessandrogiordano.assetx@gmail.com", "assetX1125");
                    transport.sendMessage(message, message.getAllRecipients());
                    return true;
                } catch (MessagingException mex) {
                    mex.printStackTrace();
                    return false;
                }
            }
        %>
    </body>
</html>