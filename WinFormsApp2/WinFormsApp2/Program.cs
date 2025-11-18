namespace WinFormsApp2
{
    internal static class Program
    {
        /// <summary>
        ///  The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main(string[] args)//string _division, string _fm_key)
        {
            string[] s = args[0].ToString().Split(",");
            //string[] s = { "D:CPD", "F:202407", "U:admin1", "L:Compare","S:10.240.65.33","A:SC2" };// 
            //string[] s = { "D:CPD", "F:202407", "U:admin1", "L:TEST" };// 
            //string[] s = { "D:CPD", "F:202407", "U:admin1", "L:TEST1" };// 
            //string[] s = { "D:CPD", "F:202407", "U:admin1", "L:TEST2" };// 
            //string[] s = { "D:CPD", "F:202407", "U:admin1", "L:REPORT" };// 

            //MessageBox.Show(s.Length.ToString());
            int s2_length = 0;
            //int _current_length = 0;
            foreach (string s2 in s) 
            {
                s2_length = s2.Length;

                if (s2.Substring(0, 2) == "D:")
                {
                    Connection_SQL._division = s2.Substring(2, 3);
                    //MessageBox.Show("Division: = " + s2.Substring(2,3));
                }
                else if (s2.Substring(0, 2) == "F:")
                {
                    Connection_SQL._fmkey = s2.Substring(2, 6);
                    //MessageBox.Show("FM_KEY: = " + s2.Substring(2,6));
                }
                else if (s2.Substring(0, 2) == "U:")
                {
                    Connection_SQL._userID = s2.Substring(2, (s2_length - 2));
                    //MessageBox.Show("FM_KEY: = " + s2.Substring(2,(s2_length-2)));
                }
                else if (s2.Substring(0, 2) == "L:")
                {
                    Connection_SQL._form_active = s2.Substring(2, (s2_length - 2));
                    //MessageBox.Show("FM_KEY: = " + s2.Substring(2,(s2_length-2)));
                }
                else if (s2.Substring(0, 2) == "S:")//server name
                {
                    Connection_SQL._serverName = s2.Substring(2, (s2_length - 2));
                }
                else if (s2.Substring(0, 2) == "A:")//database name
                {
                    Connection_SQL._DatabaseName = s2.Substring(2, (s2_length - 2));
                }
                //_current_length = _current_length + s2.Length;
            }
            //MessageBox.Show(Connection_SQL._DatabaseName);
            //MessageBox.Show(Connection_SQL._division);
            //MessageBox.Show(args[0]);
            //MessageBox.Show(args[0].ToString().Split(","));
            
            // To customize application configuration such as set high DPI settings or default font,
            // see https://aka.ms/applicationconfiguration.
            ApplicationConfiguration.Initialize();
            if (Connection_SQL._form_active == "Compare")
            {
                Application.Run(new Frm_Devexpress_Gridcontrol(Connection_SQL._division, Connection_SQL._fmkey));
                //Application.Run(new FrmTEST());
            }
            //else if (Connection_SQL._form_active == "Filter")
            //{
            //    Application.Run(new Frm_FilterColumn());
            //}
            //else if (Connection_SQL._form_active == "TEST1")
            //{
            //    Application.Run(new FrmTEST());
            //}
            //else if (Connection_SQL._form_active == "TEST2")
            //{
            //    Application.Run(new Frm_MM_master());
            //}
            else if (Connection_SQL._form_active == "REPORT")
            {
                Application.Run(new FrmReport());
            }
            //Application.Run(new Form1());
        }
    }
}