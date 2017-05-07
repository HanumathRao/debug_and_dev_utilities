namespace address_resolver
{
    partial class AddressResolverForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.buttonResolve = new System.Windows.Forms.Button();
            this.label_portable_executable = new System.Windows.Forms.Label();
            this.label_address = new System.Windows.Forms.Label();
            this.label_function_name = new System.Windows.Forms.Label();
            this.textBox_pe_file = new System.Windows.Forms.TextBox();
            this.textBox_address = new System.Windows.Forms.TextBox();
            this.textBox_function_name = new System.Windows.Forms.TextBox();
            this.button_choose_file = new System.Windows.Forms.Button();
            this.openFileDialogPDBFile = new System.Windows.Forms.OpenFileDialog();
            this.SuspendLayout();
            // 
            // buttonResolve
            // 
            this.buttonResolve.Location = new System.Drawing.Point(370, 65);
            this.buttonResolve.Name = "buttonResolve";
            this.buttonResolve.Size = new System.Drawing.Size(176, 23);
            this.buttonResolve.TabIndex = 0;
            this.buttonResolve.Text = "Resolve";
            this.buttonResolve.UseVisualStyleBackColor = true;
            this.buttonResolve.Click += new System.EventHandler(this.buttonResolve_Click);
            // 
            // label_portable_executable
            // 
            this.label_portable_executable.AutoSize = true;
            this.label_portable_executable.Location = new System.Drawing.Point(12, 28);
            this.label_portable_executable.Name = "label_portable_executable";
            this.label_portable_executable.Size = new System.Drawing.Size(40, 13);
            this.label_portable_executable.TabIndex = 1;
            this.label_portable_executable.Text = "PE File";
            // 
            // label_address
            // 
            this.label_address.AutoSize = true;
            this.label_address.Location = new System.Drawing.Point(12, 65);
            this.label_address.Name = "label_address";
            this.label_address.Size = new System.Drawing.Size(67, 13);
            this.label_address.TabIndex = 2;
            this.label_address.Text = "Hex Address";
            // 
            // label_function_name
            // 
            this.label_function_name.AutoSize = true;
            this.label_function_name.Location = new System.Drawing.Point(12, 115);
            this.label_function_name.Name = "label_function_name";
            this.label_function_name.Size = new System.Drawing.Size(79, 13);
            this.label_function_name.TabIndex = 3;
            this.label_function_name.Text = "Function Name";
            // 
            // textBox_pe_file
            // 
            this.textBox_pe_file.Location = new System.Drawing.Point(116, 20);
            this.textBox_pe_file.Name = "textBox_pe_file";
            this.textBox_pe_file.Size = new System.Drawing.Size(338, 20);
            this.textBox_pe_file.TabIndex = 4;
            // 
            // textBox_address
            // 
            this.textBox_address.Location = new System.Drawing.Point(116, 65);
            this.textBox_address.Name = "textBox_address";
            this.textBox_address.Size = new System.Drawing.Size(196, 20);
            this.textBox_address.TabIndex = 5;
            // 
            // textBox_function_name
            // 
            this.textBox_function_name.Location = new System.Drawing.Point(116, 115);
            this.textBox_function_name.Name = "textBox_function_name";
            this.textBox_function_name.Size = new System.Drawing.Size(430, 20);
            this.textBox_function_name.TabIndex = 6;
            // 
            // button_choose_file
            // 
            this.button_choose_file.Location = new System.Drawing.Point(471, 20);
            this.button_choose_file.Name = "button_choose_file";
            this.button_choose_file.Size = new System.Drawing.Size(75, 23);
            this.button_choose_file.TabIndex = 7;
            this.button_choose_file.Text = "Choose File";
            this.button_choose_file.UseVisualStyleBackColor = true;
            this.button_choose_file.Click += new System.EventHandler(this.button_choose_file_Click);
            // 
            // openFileDialogPDBFile
            // 
            this.openFileDialogPDBFile.FileName = "openFileDialogPDBFile";
            // 
            // AddressResolverForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(563, 164);
            this.Controls.Add(this.button_choose_file);
            this.Controls.Add(this.textBox_function_name);
            this.Controls.Add(this.textBox_address);
            this.Controls.Add(this.textBox_pe_file);
            this.Controls.Add(this.label_function_name);
            this.Controls.Add(this.label_address);
            this.Controls.Add(this.label_portable_executable);
            this.Controls.Add(this.buttonResolve);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "AddressResolverForm";
            this.Text = "Address Resolver";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button buttonResolve;
        private System.Windows.Forms.Label label_portable_executable;
        private System.Windows.Forms.Label label_address;
        private System.Windows.Forms.Label label_function_name;
        private System.Windows.Forms.TextBox textBox_pe_file;
        private System.Windows.Forms.TextBox textBox_address;
        private System.Windows.Forms.TextBox textBox_function_name;
        private System.Windows.Forms.Button button_choose_file;
        private System.Windows.Forms.OpenFileDialog openFileDialogPDBFile;
    }
}

