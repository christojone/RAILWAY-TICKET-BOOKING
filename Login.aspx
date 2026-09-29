<%@ Page Language="C#" MasterPageFile="~/Site.master" %>
<script runat="server">
    void Done(System.Data.DataRow r)
    {
        Session["UserId"] = r["UserId"]; Session["Name"] = r["Name"];
        string ret = Request.QueryString["ret"];
        Response.Redirect(string.IsNullOrEmpty(ret) || !ret.EndsWith(".aspx") && !ret.Contains(".aspx?") ? "Default.aspx" : ret);
    }
    protected void btnLogin_Click(object s, EventArgs e)
    {
        var t = Db.Table("SELECT * FROM Users WHERE Email=@e AND Password=@p", Db.P("@e", txtEmail.Text.Trim()), Db.P("@p", Db.Hash(txtPass.Text)));
        if (t.Rows.Count == 1) Done(t.Rows[0]); else lblMsg.Text = "Invalid email or password.";
    }
    protected void btnReg_Click(object s, EventArgs e)
    {
        if ((int)Db.Scalar("SELECT COUNT(*) FROM Users WHERE Email=@e", Db.P("@e", rEmail.Text.Trim())) > 0) { lblMsg.Text = "Email already registered."; return; }
        Db.Exec("INSERT Users(Name,Email,Password) VALUES(@n,@e,@p)", Db.P("@n", rName.Text.Trim()), Db.P("@e", rEmail.Text.Trim()), Db.P("@p", Db.Hash(rPass.Text)));
        Done(Db.Table("SELECT * FROM Users WHERE Email=@e", Db.P("@e", rEmail.Text.Trim())).Rows[0]);
    }
</script>
<asp:Content ContentPlaceHolderID="body" runat="server">
  <asp:Label ID="lblMsg" runat="server" CssClass="text-danger d-block mb-2" />
  <div class="row g-4">
    <div class="col-md-6"><div class="card p-4 shadow-sm"><h4>Login</h4>
      <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control mb-2" placeholder="Email" />
      <asp:TextBox ID="txtPass" runat="server" TextMode="Password" CssClass="form-control mb-2" placeholder="Password" />
      <asp:Button ID="btnLogin" runat="server" Text="Login" CssClass="btn btn-primary" OnClick="btnLogin_Click" /></div></div>
    <div class="col-md-6"><div class="card p-4 shadow-sm"><h4>New User? Register</h4>
      <asp:TextBox ID="rName" runat="server" CssClass="form-control mb-2" placeholder="Full name" />
      <asp:TextBox ID="rEmail" runat="server" CssClass="form-control mb-2" placeholder="Email" />
      <asp:TextBox ID="rPass" runat="server" TextMode="Password" CssClass="form-control mb-2" placeholder="Password" />
      <asp:Button ID="btnReg" runat="server" Text="Register" CssClass="btn btn-success" OnClick="btnReg_Click" /></div></div>
  </div>
</asp:Content>
