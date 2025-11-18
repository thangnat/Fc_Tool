using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using Excel = Microsoft.Office.Interop.Excel;
using Office = Microsoft.Office.Core;
using Microsoft.Office.Tools.Excel;

namespace EXCEL_ADDINS
{
    public partial class ThisAddIn
    {
        // User control
        //private System.Windows.Forms.UserControl _usr;
        // Custom task pane
        public static Microsoft.Office.Tools.CustomTaskPane _myCustomTaskPane;
        private void ThisAddIn_Startup(object sender, System.EventArgs e)
        {
            ////Create an instance of the user control
            //_usr = new UTaskPane();
            //// Connect the user control and the custom task pane 
            //_myCustomTaskPane = CustomTaskPanes.Add(_usr, "____");
            //_myCustomTaskPane.Visible = true;           
            //_myCustomTaskPane.DockPosition = Office.MsoCTPDockPosition.msoCTPDockPositionTop;
            //_myCustomTaskPane.Height = 80;
        }

        private void ThisAddIn_Shutdown(object sender, System.EventArgs e)
        {

        }

        #region VSTO generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InternalStartup()
        {
            this.Startup += new System.EventHandler(ThisAddIn_Startup);
            this.Shutdown += new System.EventHandler(ThisAddIn_Shutdown);
        }
        
        #endregion
    }
}
