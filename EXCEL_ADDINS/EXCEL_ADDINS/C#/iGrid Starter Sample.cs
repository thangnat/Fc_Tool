using System;
using System.Drawing;
using System.Windows.Forms;

namespace SamplesCS
{
    public partial class FormStarterSample : Form
    {
        public FormStarterSample()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            //// Create a grid with 2 columns and 5 rows
            //iGrid1.Cols.Count = 2;
            //iGrid1.Rows.Count = 5;

            //// Set column captions
            //iGrid1.Cols[0].Text = "Column 1";
            //iGrid1.Cols[1].Text = "Column 2";

            //// Set some values in the first 2 cells in the first column
            //iGrid1.Cells[0, 0].Value = "abc";
            //iGrid1.Cells[1, 0].Value = 123;

            //// The first cell in the second column will display
            //// the current date in red using the long date pattern
            //iGrid1.Cells[0, 1].Value = DateTime.Now;
            //iGrid1.Cells[0, 1].FormatString = "{0:D}";
            //iGrid1.Cells[0, 1].ForeColor = Color.Red;

            //// Automatically adjust the width of the second column
            //// to display its contents without clipping
            //iGrid1.Cols[1].AutoWidth();
        }
    }
}