using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace address_resolver
{
    public partial class AddressResolverForm : Form
    {
        public AddressResolverForm()
        {
            InitializeComponent();
        }

        private void buttonResolve_Click(object sender, EventArgs e)
        {
            try
            {
                textBox_function_name.Text = "";
                textBox_function_name.Text = AddressResolver.getMethodNameFromAddress(textBox_pe_file.Text, textBox_address.Text);
            }
            catch(Exception ex)
            {
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void button_choose_file_Click(object sender, EventArgs e)
        {
            openFileDialogPDBFile = new OpenFileDialog();
            openFileDialogPDBFile.Filter = "*.exe|*.dll";
            DialogResult result = openFileDialogPDBFile.ShowDialog();
            if (result == DialogResult.OK) // Test result.
            {
                textBox_pe_file.Text = openFileDialogPDBFile.FileName;
            }
        }
    }
}
