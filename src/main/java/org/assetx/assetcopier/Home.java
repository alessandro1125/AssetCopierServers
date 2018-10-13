package org.assetx.assetcopier;


import javax.servlet.RequestDispatcher;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(
        name = "HomeServlet",
        urlPatterns = {"/"}
)
public class Home extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp){

        //Controllo se il protocollo è https
        Utils.checkForHttpsProtocol(req, resp);

        try {
            RequestDispatcher view;
            view = req.getRequestDispatcher("/login");
            view.forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp){
        doGet(req, resp);
    }
}
