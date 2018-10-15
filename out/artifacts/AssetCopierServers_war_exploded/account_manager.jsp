<%@ page import="java.util.GregorianCalendar" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.assetx.libraries.utils.SqlUtils" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="org.assetx.assetcopier.Login.User" %>
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
         * 2 - aggiorno i parametri mt4
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

        // Ricavo i parametri mt4 da mail
        User user = Login.getUser(null, email);
        assert user != null;
        Login.Mt4Params mtParams = new Login.Mt4Params(user.mt_params);

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
            <h2>ID CONTO</h2>
            <p style="display: inline">Current Account Id: <%=accountId%></p>
            <br>
            <form action="account_manager?handle_action=1"
                  method="post" enctype="application/x-www-form-urlencoded">
                <input type="text" name="new_id" placeholder="Enter a new Account ID...">
                <input type="submit" value="Update ID">
            </form>
        </div>


        <div class="form-style-8">
            <h2>MT4 PARAMS</h2>
            <form action="account_manager?handle_action=2"
                  method="post" enctype="application/x-www-form-urlencoded">
                <p><b>Channel</b></p>
                <input type="text" name="channel" id="channel" value="<%=mtParams.channel%>" placeholder="Enter a Channel...">
                <p><b>Fixed Size</b></p>
                <input type="text" name="fixed_size" id="fixed_size" value="<%=mtParams.fixedSize%>" placeholder="Enter fixed size...">
                <p><b>Multipler Size</b></p>
                <input type="text" name="multipler_size" id="multipler_size" value="<%=mtParams.multiplerSize%>" placeholder="Enter multipler size...">
                <p><b>Automatic Size</b></p>
                <select name="automatic_size">
                    <% if (mtParams.automaticSize.equals("true")) { %>
                        <option value="true" selected="selected">true</option>
                        <option value="false">false</option>
                    <% } else { %>
                        <option value="true">true</option>
                        <option value="false" selected="selected">false</option>
                    <% } %>
                </select>
                <p><b>Risk</b></p>
                <input type="text" name="risk" id="risk" value="<%=mtParams.risk%>" placeholder="Enter risk (%)...">
                <p><b>Pip StopLoss Default</b></p>
                <input type="text" name="pip_stoploss_default" id="pip_stoploss_default" value="<%=mtParams.pipStopLossDefault%>" placeholder="Enter pip stop loss...">
                <p><b>Minimum Size</b></p>
                <input type="text" name="minimum_size" id="minimum_size" value="<%=mtParams.minimumSize%>" placeholder="Enter minimum size...">
                <p><b>Order Validity Time</b></p>
                <input type="text" name="order_validity_time" id="order_validity_time" value="<%=mtParams.orderValidityTime%>" placeholder="Enter order validity time...">
                <p><b>Slippage</b></p>
                <input type="text" name="slippage" id="slippage" value="<%=mtParams.slippage%>" placeholder="Enter slippage..">
                <p><b>Asset to Esclude</b></p>
                <input type="text" name="asset_to_esclude" id="asset_to_esclude" value="<%=mtParams.assetToEsclude%>" placeholder="Enter assets to esclude...">
                <p><b>Suffix</b></p>
                <input type="text" name="suffix" id="suffix" value="<%=mtParams.suffix%>" placeholder="Enter suffix...">
                <input type="submit" value="Update MT4 Params">
            </form>
        </div>

        <script type="application/javascript">


            var channelObj = doucument.getElementById("channel");
            channelObj.addEventListener('input', checkParamsInputs);
            var fixedSizeObj = doucument.getElementById("fixed_size");
            fixedSizeObj.addEventListener('input', checkParamsInputs);
            var multiplerSizeObj = doucument.getElementById("multipler_size");
            multiplerSizeObj.addEventListener('input', checkParamsInputs);
            var riskObj = doucument.getElementById("risk");
            riskObj.addEventListener('input', checkParamsInputs);
            var pipStoplossDefaultObj = doucument.getElementById("pip_stoploss_default");
            pipStoplossDefaultObj.addEventListener('input', checkParamsInputs);
            var minimumlObj = doucument.getElementById("minimum_size");
            minimumlObj.addEventListener('input', checkParamsInputs);
            var orderValiditytimeObj = doucument.getElementById("oder_validity_time");
            orderValiditytimeObj.addEventListener('input', checkParamsInputs);
            var slippageObj = doucument.getElementById("slippage");
            slippageObj.addEventListener('input', checkParamsInputs);
            var assetToEscludeObj = doucument.getElementById("asset_to_esclude");
            assetToEscludeObj.addEventListener('input', checkParamsInputs);
            var suffixObj = doucument.getElementById("suffix");
            suffixObj.addEventListener('input', checkParamsInputs);


            channelObj.style.borderColor = '#28d682';
            channelObj.style.borderWidth = '2px';

            function checkParamsInputs() {
                var channel = channelObj.value;
                var fixedSize = fixedSizeObj.value;
                var multiplerSize = multiplerSizeObj.value;
                var risk = riskObj.value;
                var pipStopLossDefault = pipStoplossDefaultObj.value;
                var minimuimSize = minimumlObj.value;
                var oderValidityTime = orderValiditytimeObj.value;
                var slippage = slippageObj.value;
                var assetToEsclude = assetToEscludeObj.value;
                var suffix = suffixObj.value;

                var channelCorr = true;
                for (var i = 0; i < channel.length; i++) {
                    if (isNaN(parseInt(channel.substr(i, 1), 10))) {
                        channelCorr = false;
                    }
                }
                setBorders(channelObj, channelCorr);


            }

            function setBorders(object, condition) {
                if (condition) {
                    object.style.borderColor = '#28d682';
                }else {
                    object.style.borderColor = '#cc4949';
                }
            }
            
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