package org.assetx.assetcopier;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;

@WebServlet(
        name = "ServletStylesManager",
        urlPatterns = "/styles/*"
)
public class StylesManager extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {

        //Controllo se il protocollo è https
        //Utils.checkForHttpsProtocol(request, response);

        //Reindirizzo all'unica page .css
        try {
            OutputStream outputStream = response.getOutputStream();
            FileInputStream fileInputStream = new FileInputStream(getClass().getResource("/stile-1.css").getFile());

            int bytes;
            while ((bytes = fileInputStream.read()) != -1) {
                outputStream.write(bytes);
            }
            outputStream.flush();
            outputStream.close();
            fileInputStream.close();
        }catch (IOException e){
            e.printStackTrace();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response){
        doGet(request, response);
    }

}