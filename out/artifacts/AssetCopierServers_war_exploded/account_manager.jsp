<%@ page import="java.util.GregorianCalendar" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.assetx.libraries.utils.SqlUtils" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="org.assetx.assetcopier.Login" %>
<%@ page contentType="text/html;charset=UTF-8"%>
<html>
    <head>
        <%

            //Controllo se sono autorizzato
            try {
                if (!((String)request.getAttribute("authorization")).equals("authorized")) {
                    //Se non sono autorizzato reindirizzo l'utente alla home
                    System.out.println("Richieesta non autorizzata");
                    String redirectURL = "/";
                    response.sendRedirect(redirectURL);
                }
            }catch (Exception e){
                e.printStackTrace();
                //Se non sono autorizzato reindirizzo l'utente alla home
                String redirectURL = "/";
                response.sendRedirect(redirectURL);
            }

            //Provo autenticazione utente con cookie
            boolean cookieAuthentication = false;
            String email = null;
            Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                String password = null;
                for (Cookie cookie : cookies) {
                    try {
                        if (cookie.getName().equals("email"))
                            email = cookie.getValue();
                        if (cookie.getName().equals("password"))
                            password = cookie.getValue();
                    } catch (NullPointerException e) {
                        e.printStackTrace();
                    }
                }
                if (email != null && password != null) {
                    //Faccio il login
                    try {
                        if (Login.authenticateUser(null, email, password) == 0) {
                            cookieAuthentication = true;
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            }
        %>
        <title>AssetCopier Account Manager</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3mobile.css">
        <link rel="stylesheet" href="/styles" type="text/css">

        <style type="text/css">

        </style>
    </head>
    <body style="position: absolute; min-width: 1000px; width: 100%">
    <%
        //Ricavo l'eventuale action
        int action = 0;
        try {
            action = Integer.parseInt(request.getParameter("handle_action"));
        }catch (Exception e){}
        //Ricavo l'eventuale email
        try {
            String emailAtt = null;
            emailAtt = (String)request.getAttribute("email");
            if (emailAtt != null)
                email = emailAtt;
        }catch (Exception e){
            e.printStackTrace();
            //Se non sono autorizzato reindirizzo l'utente alla home
            System.out.println("Email non presente");
            String redirectURL = "/";
            response.sendRedirect(redirectURL);
        }


        /**
         *
         * ACTIONS:
         *
         * 1 - aggiorno l'account id
         *
         */
        switch (action){
            case 1:
                //AGGIORNO L'ACCOUNT ID
                System.out.println("Updating asccount id");
                String account_id;
                try {
                    account_id = request.getParameter("new_id");
                }catch (Exception e){
                    e.printStackTrace();
                    break;
                }
                //Lo inserisco nel DB
                HashMap<String, String> map = new HashMap<>();
                map.put("account_id", account_id);
                HashMap<String, String> params = new HashMap<>();
                params.put("email", email);
                SqlUtils.sqlUpdate(SqlUtils.getConnectionHeroku(), "users", map, params);
                break;
            default: break;
        }

        //Ricavo l'account id attuale
        String accountId = "No ID";
        Connection connection = SqlUtils.getConnectionHeroku();
        ResultSet resultSet = SqlUtils.sqlSelect(connection, "users", null, "email='" + email + "'");
        //Analizzo il resultSet per trovare l'account ID
        try {
            assert resultSet != null;
            resultSet.next();
            accountId = resultSet.getString("account_id");
        }catch (SQLException e){
            e.printStackTrace();
        }
    %>
        <div id="toolbar" class="form-style-8" style="font-family: 'Open Sans Condensed', sans-serif;
        min-width: 1000px;
        max-width: 100%;
        width: 100%;
        margin-top: 0;
        height: 70px;
        padding: 10px;
        background: #ff4d4d;
        box-shadow: 0 0 20px rgba(0, 0, 0, 0.22);
        -moz-box-shadow: 0 0 15px rgba(0, 0, 0, 0.22);
        -webkit-box-shadow:  0 0 15px rgba(0, 0, 0, 0.22);">
            <h1>Account Manager</h1>
            <input type="button" value="Log Out" class="form-style-1" onclick="logOut()" style=
                "border-radius: 2px; width: 100px; position: absolute;
                 right: 20px; color: #e6e6e6; display: inline;">
        </div>
        <div class="form-style-1">
            <input type="button" style="width: 250px" value="Download Assetcopier"
                   onclick="download_software()">
        </div>

        <div class="form-style-8">
            <p style="display: inline">Current Account Id: <%=accountId%></p>
            <br>
            <form action="account_manager?handle_action=1"
                  method="post" enctype="application/x-www-form-urlencoded">
                <input type="text" name="new_id" placeholder="Enter a new Account ID...">
                <input type="submit" value="Update ID">
            </form>
        </div>


        <div class="form-style-8">
            <p style="display: inline">Current Account Id: <%=accountId%></p>
            <br>
            <form action="account_manager?handle_action=2"
                  method="post" enctype="application/x-www-form-urlencoded">
                <input type="text" name="new_id" placeholder="Enter a new Account ID...">
                <input type="submit" value="Update ID">
            </form>
        </div>

        <script type="application/javascript">

            function download_software() {
                //Link di downlaod
                window.location.href = "/download_zip";
            }

            function logOut() {
                //Cancello i cookie
                document.cookie = "email"+'=; Max-Age=-99999999;';
                document.cookie = "password"+'=; Max-Age=-99999999;';
                document.cookie = "software_name"+'=; Max-Age=-99999999;';
                //Log Out
                window.location.replace("/login");
            }
        </script>
    </body>
</html>