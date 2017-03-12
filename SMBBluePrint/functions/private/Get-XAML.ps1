

function Get-XAML {
    [OutputType([hashtable])]
    [cmdletbinding()]
    $xaml = @{

    GUI = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        DataContext="{Binding ViewModel}"
        Title="Microsoft Azure Small Business Server Solution Accelerator" Height="Auto" Width="Auto" SizeToContent="WidthAndHeight" Background="White" WindowStyle="None">
    <Window.Resources>
        <Style TargetType="{x:Type Button}">
            <Setter Property="HorizontalAlignment" Value="Left" />
            <Setter Property="VerticalAlignment" Value="Top" />
            <Setter Property="Margin" Value="10" />
        </Style>
    </Window.Resources>
    <Grid Height="Auto">
        <Grid.ColumnDefinitions>
            <ColumnDefinition Name="SectionColumn" Width="100" />
            <ColumnDefinition Name="ContentColumn"   />
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Name="MainTitle" Height="35"  />
            <RowDefinition Name="MainHeaders" Height="Auto" />
            <RowDefinition Name="MainTabs" Height="Auto" />
            <RowDefinition Name="MainButtons" Height="Auto" />
            <RowDefinition Name="Log" Height="*" />
            <RowDefinition Name="Logo" Height="Auto" />

        </Grid.RowDefinitions>
        <Grid Grid.Row="0" Grid.ColumnSpan="2" >
            <Grid.Background>
                <SolidColorBrush Color="#FF0088FF" />
            </Grid.Background>
            <TextBlock Name="Lbl_Title" Grid.Column="0" VerticalAlignment="Center" HorizontalAlignment="Center" FontSize="20" Foreground="White">SMB Deployment GUI</TextBlock>
            <StackPanel Orientation="Horizontal" Grid.Column="1" HorizontalAlignment="Right">
                <Button Name="CloseButton" Height="35" Width="35" HorizontalAlignment="Right" VerticalAlignment="Top" FontWeight="Bold" FontSize="14" Margin="0,0">
                    <Button.Background>
                        <SolidColorBrush Opacity="100" />
                    </Button.Background>
                    <Button.Foreground>
                        <SolidColorBrush Color="White" />
                    </Button.Foreground>
                    <Button.BorderBrush>
                        <SolidColorBrush Opacity="100" />
                    </Button.BorderBrush>
                    X
                </Button>
            </StackPanel>
        </Grid>
        <Grid Grid.Row="5" Grid.ColumnSpan="2">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Name="HeaderLeft" />
                <ColumnDefinition Name="HeaderRight" />
            </Grid.ColumnDefinitions>

            <StackPanel Grid.Column="0">
                <Image Name="AzureLogo" Source="D:\OneDrive - Inovativ\Projects\Microsoft\SBS\dev\GUI\src\azure.png" Stretch="Fill" HorizontalAlignment="Left" Width="150" Height="50"  />
                <TextBlock FontSize="20">SMB Blueprint</TextBlock>
            </StackPanel>
            <StackPanel Grid.Column="1" VerticalAlignment="Bottom">
                <Image Name="MicrosoftLogo" Source="D:\OneDrive - Inovativ\Projects\Microsoft\SBS\dev\GUI\src\microsoft.png" VerticalAlignment="Stretch" HorizontalAlignment="Right" Height="50" Width="300"  />
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                    <TextBlock HorizontalAlignment="Right" VerticalAlignment="Center">Powered By</TextBlock>
                    <Image Name="InovativLogo" Source="D:\OneDrive - Inovativ\Projects\Microsoft\SBS\dev\GUI\src\inovativ.png" Height="20" Width="90" HorizontalAlignment="Right" VerticalAlignment="Center" />

                </StackPanel>


            </StackPanel>


        </Grid>
        <Grid Grid.Row="2" Grid.Column="0">
            <Grid.Resources>

            </Grid.Resources>
            <StackPanel VerticalAlignment="Stretch" HorizontalAlignment="Center">
                <Button Name="Btn_HomeLink">
                    <Button.Background>
                        <SolidColorBrush Opacity="100" />
                    </Button.Background>
                    <Button.Foreground>
                        <SolidColorBrush Color="Blue" />
                    </Button.Foreground>
                    <Button.BorderBrush>
                        <SolidColorBrush Opacity="100" />
                    </Button.BorderBrush> Home
                </Button>
                <Button Name="Btn_O365Link">
                    <Button.Background>
                        <SolidColorBrush Opacity="100" />
                    </Button.Background>
                    <Button.Foreground>
                        <SolidColorBrush Color="Blue" />
                    </Button.Foreground>
                    <Button.BorderBrush>
                        <SolidColorBrush Opacity="100" />
                    </Button.BorderBrush> Office 365
                </Button>
                <Button Name="Btn_AzureLink">

                    <Button.Background>
                        <SolidColorBrush Opacity="100" />
                    </Button.Background>
                    <Button.Foreground>
                        <SolidColorBrush Color="Blue" />
                    </Button.Foreground>
                    <Button.BorderBrush>
                        <SolidColorBrush Opacity="100" />
                    </Button.BorderBrush> Azure
                </Button>
                <Button Name="Btn_LogLink">
                    <Button.Background>
                        <SolidColorBrush Opacity="100" />
                    </Button.Background>
                    <Button.Foreground>
                        <SolidColorBrush Color="Blue" />
                    </Button.Foreground>
                    <Button.BorderBrush>
                        <SolidColorBrush Opacity="100" />
                    </Button.BorderBrush> Log
                </Button>
            </StackPanel>
        </Grid>
        <TabControl Name="Tab_MainControl" Grid.Row="2" Grid.Column="1" BorderThickness="0">
            <TabControl.ItemContainerStyle>
                <Style x:Name="Style_HideTabs" TargetType="{x:Type TabItem}">


                    <Setter Property="Visibility" Value="{Binding RelativeSource={RelativeSource Mode=FindAncestor,AncestorType=Window}, Path=DataContext.TabState}"/>




                </Style>
            </TabControl.ItemContainerStyle>

            <TabItem Name="General" Header="General" >
                <Grid>
                    <!--<GroupBox Name="Grp_O365Connection" Header="Microsoft O365 Connection" Margin="0,50,0,0">
                        <Grid>
                            <Label Margin="0,5,0,0" VerticalAlignment="Top" HorizontalAlignment="Left">User:</Label>
                            <TextBox Name="Txt_OLogonUser" Margin="100,10,0,0" VerticalAlignment="Top" HorizontalAlignment="Left" Width="150" />
                            <Label VerticalAlignment="Top" Margin="270,5,0,0" HorizontalAlignment="Left">Password:</Label>
                            <PasswordBox Name="Txt_OLogonPass" Margin="340,10,0,0" VerticalAlignment="Top" HorizontalAlignment="Left" Width="100"  />
                            <Button Name="Btn_ConnectToO365" Margin="470,10,0,0" VerticalAlignment="Top">Connect</Button>
                            <Label Margin="0,40,0,0" VerticalAlignment="Top" HorizontalAlignment="Left">Tenant Domain:</Label>
                            <TextBox Name="Txt_ODomain" Margin="100,45,0,0" VerticalAlignment="Top" HorizontalAlignment="Left" Width="150" />
                            <Label Margin="250,40,0,0" VerticalAlignment="Top" HorizontalAlignment="Left">.onmicrosoft.com</Label>
                        </Grid>
                    </GroupBox> -->
                    <GroupBox Name="Grp_AConnection" Header="Microsoft Azure Connection" Height="100" VerticalAlignment="Top">
                        <StackPanel>
                            <StackPanel Orientation="Horizontal">
                                <Label VerticalAlignment="Center" HorizontalAlignment="Left">User:</Label>
                                <TextBox Name="Txt_LogonUser" VerticalAlignment="Center" HorizontalAlignment="Left" Width="300" />
                                <Label HorizontalAlignment="Left" VerticalAlignment="Center">Password:</Label>
                                <PasswordBox Name="Txt_LogonPass" VerticalAlignment="Center" HorizontalAlignment="Left" Width="150"  />
                                <Button Name="Btn_ConnectToAzure" VerticalAlignment="Center" IsDefault="True">Connect</Button>
                            </StackPanel>
                            <StackPanel Orientation="Horizontal">
                                <Label VerticalAlignment="Center" HorizontalAlignment="Left">Tenant:</Label>
                                <ComboBox Name="Cmb_Tenants" VerticalAlignment="Center" HorizontalAlignment="Left" Width="300" />
                            </StackPanel>
                        </StackPanel>
                    </GroupBox>
                </Grid>
            </TabItem>
            <TabItem Name="Tab_O365" Header="O365">
                <StackPanel>

                    <Button Margin="0,0,0,0" HorizontalAlignment="Center" Name="btnImportCSV" Height="20" Width="100" VerticalAlignment="Center" Background="#FF8B97A2" Foreground="White" FontWeight="ExtraBold">Import CSV...</Button>

                    <!--<GroupBox Margin="0,10,711.2,553.4" Name="Grp_TenantInf" Header="Tenant Information">
                        <Grid Margin="0,0,0,0">
                            <Label VerticalAlignment="Top" Margin="0,0,0,0" HorizontalAlignment="Left">Tenant Name:</Label>
                            <TextBox Name="Txt_TenantName" Margin="100,5,0,0" VerticalAlignment="Top" HorizontalAlignment="Left" Width="250" />
                            <Label VerticalAlignment="Top" Margin="0,35,0,0" HorizontalAlignment="Left">Address:</Label>
                            <TextBox Name="txt_TenantAddress" Margin="100,40,0,0" VerticalAlignment="Top" HorizontalAlignment="Left" Width="250" />
                            <Label VerticalAlignment="Top" Margin="0,70,0,0" HorizontalAlignment="Left">Number:</Label>
                            <TextBox Name="txt_AddNumber" Margin="100,75,0,0" VerticalAlignment="Top" HorizontalAlignment="Left" Width="50" />
                            <Label VerticalAlignment="Top" Margin="0,105,0,0" HorizontalAlignment="Left">ZIP:</Label>
                            <TextBox Name="txt_TenantZIP" Margin="100,110,0,0" VerticalAlignment="Top" HorizontalAlignment="Left" Width="50" />
                            <Label VerticalAlignment="Top" Margin="0,140,0,0" HorizontalAlignment="Left">State:</Label>
                            <TextBox Name="txt_TenantState" Margin="100,145,0,0" VerticalAlignment="Top" HorizontalAlignment="Left" Width="250" />
                            <Label VerticalAlignment="Top" Margin="160,105,0,0" HorizontalAlignment="Left">City:</Label>
                            <TextBox Name="txt_City" Margin="200,110,0,0" VerticalAlignment="Top" HorizontalAlignment="Left" Width="150" />
                            <Label VerticalAlignment="Top" Margin="0,170,0,0" HorizontalAlignment="Left">Country:</Label>
                            <TextBox Name="txt_TenantCountry" Margin="100,175,0,0" VerticalAlignment="Top" HorizontalAlignment="Left" Width="250" />
                            <Label VerticalAlignment="Top" Margin="0,205,0,0" HorizontalAlignment="Left">Office Phone:</Label>
                            <TextBox Name="txt_TenantPh" Margin="100,210,0,0" VerticalAlignment="Top" HorizontalAlignment="Left" Width="250" />
                            <Label VerticalAlignment="Top" Margin="0,240,0,0" HorizontalAlignment="Left">Fax Number:</Label>
                            <TextBox Name="txt_TenantFax" Margin="100,245,0,0" VerticalAlignment="Top" HorizontalAlignment="Left" Width="250" />

                        </Grid>
                    </GroupBox> -->
                    <GroupBox Name="Grp_GroupInfo" Header="Groups">
                        <StackPanel>
                            <StackPanel Orientation="Horizontal">
                                <StackPanel Orientation="Vertical" Width="240" VerticalAlignment="Center">
                                    <TextBlock TextWrapping="Wrap">Please use the user input section to manage O365 groups</TextBlock>


                                </StackPanel>
                                <StackPanel Orientation="Vertical" Margin="0,0,0,0">
                                    <DataGrid Name="GroupGrid" ItemsSource="{Binding Path=DataContext.Groups,RelativeSource={RelativeSource FindAncestor, AncestorType={x:Type Window}}}" 
                                      IsReadOnly="False" AutoGenerateColumns="False" CanUserAddRows="False" CanUserDeleteRows="False" VerticalAlignment="Top"
                                  HorizontalAlignment="Stretch" Height="150" Width="800" >
                                        <DataGrid.Resources>

                                            <DataTemplate x:Key="GetOwner">
                                                <TextBlock Text="{Binding Path=Owner,NotifyOnSourceUpdated=True}" />
                                            </DataTemplate>
                                            <DataTemplate x:Key="SetOwner">
                                                <ComboBox Name="Cmb_Owners" ItemsSource="{Binding Path=DataContext.Users,RelativeSource={RelativeSource FindAncestor, AncestorType={x:Type Window}}}" SelectedItem="{Binding Path=Owner}" />
                                            </DataTemplate>



                                        </DataGrid.Resources>

                                        <DataGrid.Columns>
                                            <DataGridTextColumn IsReadOnly="True" Header="Group Name" Width="150" Binding="{Binding Path=Name}" />
                                            <!--<DataGridTextColumn IsReadOnly="True" Header="Group Description" Width="350" Binding="{Binding Path=Description}" />-->

                                            <DataGridTextColumn IsReadOnly="True" Header="Owner" Width="150" Binding="{Binding Path=Owner}">

                                            </DataGridTextColumn>

                                        </DataGrid.Columns>
                                    </DataGrid>

                                </StackPanel>


                            </StackPanel>
                        </StackPanel>
                    </GroupBox>

                    <GroupBox Name="Grp_UserInfo" Height="Auto" Width="Auto" HorizontalAlignment="Left" VerticalAlignment="Top" Header="Users">
                        <StackPanel Orientation="Horizontal">
                            <Grid Name="Grd_UserInput">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="80" />
                                    <ColumnDefinition Width="200" />
                                </Grid.ColumnDefinitions>
                                <Grid.RowDefinitions>
                                    <RowDefinition Height="30" />
                                    <RowDefinition Height="30"  />
                                    <RowDefinition Height="30"  />
                                    <RowDefinition Height="30"  />
                                    <RowDefinition Height="30"  />
                                    <RowDefinition Height="30"  />
                                    <RowDefinition Height="30"  />
                                    <RowDefinition Height="30"  />
                                    <RowDefinition Height="80"  />
                                    <RowDefinition Height="40"  />
                                </Grid.RowDefinitions>

                                <Label Grid.Column="0" Grid.Row="0" VerticalAlignment="Center">First Name</Label>
                                <Label Grid.Column="0" Grid.Row="1"  VerticalAlignment="Center" HorizontalAlignment="Left">Last Name</Label>
                                <Label Grid.Column="0" Grid.Row="2" VerticalAlignment="Center" HorizontalAlignment="Left" >Function</Label>
                                <Label Grid.Column="0" Grid.Row="3"  VerticalAlignment="Center" >Department</Label>
                                <Label Grid.Column="0" Grid.Row="4"  VerticalAlignment="Center" HorizontalAlignment="Left" >Office</Label>
                                <Label Grid.Column="0" Grid.Row="5" VerticalAlignment="Center" >Mobile</Label>
                                <Label Grid.Column="0" Grid.Row="6" VerticalAlignment="Center" >Country</Label>
                                <Label Grid.Column="0" Grid.Row="7" VerticalAlignment="Center" >Group</Label>
                                <Label Grid.Column="0" Grid.Row="8" VerticalAlignment="Center" >Licenses</Label>
                                <TextBox Grid.Column="1" Grid.Row="0" Name="Txt_FirstName" VerticalAlignment="Center" HorizontalAlignment="Left" Width="150"></TextBox>
                                <TextBox Grid.Column="1" Grid.Row="1"  VerticalAlignment="Center" HorizontalAlignment="Left" Name="Txt_LastName" Width="150"></TextBox>
                                <TextBox Grid.Column="1" Grid.Row="2"   VerticalAlignment="Center" HorizontalAlignment="Left" Name="Txt_Function" Width="150"></TextBox>
                                <TextBox Grid.Column="1" Grid.Row="3"  VerticalAlignment="Center" HorizontalAlignment="Left" Name="Txt_Department" Width="150"></TextBox>
                                <TextBox Grid.Column="1" Grid.Row="4"  VerticalAlignment="Center" HorizontalAlignment="Left" Name="Txt_Office" Width="150"></TextBox>
                                <TextBox Grid.Column="1" Grid.Row="5" VerticalAlignment="Center" HorizontalAlignment="Left" Name="Txt_Mobile" Width="150"></TextBox>
                                <ComboBox Grid.Column="1" Grid.Row="6" VerticalAlignment="Center" HorizontalAlignment="Left" Name="Cmb_Country" Width="150">
                                    <ComboBoxItem Tag="BE" IsSelected="True">Belgium</ComboBoxItem>
                                    <ComboBoxItem Tag="NL" IsSelected="False">Netherlands</ComboBoxItem>
                                    <ComboBoxItem Tag="LU" IsSelected="False">Luxembourg</ComboBoxItem>
                                </ComboBox>
                                <ComboBox ItemsSource="{Binding Path=DataContext.Groups,RelativeSource={RelativeSource Mode=FindAncestor,AncestorType=Window}}" IsEditable="True" TextSearch.TextPath="Name" Grid.Column="1" Grid.Row="7" VerticalAlignment="Center" HorizontalAlignment="Left" Name="Cmb_Groups" Width="150">

                                </ComboBox>
                                <ListBox Grid.Column="1" Grid.Row="8" VerticalAlignment="Stretch" Width="Auto" Height="Auto" SelectionMode="Multiple" HorizontalAlignment="Stretch" Name="Lst_Licenses" Margin="5,5,-5,35" Grid.RowSpan="2">
                                    <ListBox.ItemTemplate>
                                        <DataTemplate>
                                            <CheckBox Name="CheckBoxZone" IsChecked="{Binding RelativeSource={RelativeSource AncestorType={x:Type ListBoxItem}}, Path=IsSelected}" Content="{Binding Path=.}" Tag="{Binding Path=.}" Margin="0,5,0,0"/>
                                        </DataTemplate>
                                    </ListBox.ItemTemplate>
                                </ListBox>

                                <Button Grid.ColumnSpan="2" Grid.Column="0" Grid.Row="9" VerticalAlignment="Top" HorizontalAlignment="Center" Name="Btn_AddUser" Height="20" Width="50" Background="#FF8B97A2" Foreground="White">Add</Button>
                            </Grid>


                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition />
                                    <ColumnDefinition />
                                </Grid.ColumnDefinitions>
                                <Grid.RowDefinitions>
                                    <RowDefinition Height="Auto" />
                                    <!--    <RowDefinition Height="Auto" /> -->
                                </Grid.RowDefinitions>
                                <DataGrid Grid.Column="0" Grid.Row="0" Name="UserGrid" ItemsSource="{Binding Path=Users,UpdateSourceTrigger=PropertyChanged,Mode=OneWay}" 
                                      IsReadOnly="True" AutoGenerateColumns="False" CanUserAddRows="False" CanUserDeleteRows="False" VerticalAlignment="Stretch" HorizontalAlignment="Stretch"
                                       Width="800" Height="360">
                                    <DataGrid.Columns>
                                        <DataGridTextColumn Header="First Name" Width="80" Binding="{Binding Path=First}" />
                                        <DataGridTextColumn Header="Last Name" Width="100" Binding="{Binding Path=Last}" />
                                        <!-- <DataGridTextColumn Header="DisplayName" Width="150" Binding="{Binding Path=First}" /> -->
                                        <DataGridTextColumn Header="Title" Width="100" Binding="{Binding Path=Title}" />
                                        <DataGridTextColumn Header="Department" Width="100" Binding="{Binding Path=Department}" />
                                        <DataGridTextColumn Header="Office" Width="100" Binding="{Binding Path=Office}" />
                                        <DataGridTextColumn Header="Mobile" Width="100" Binding="{Binding Path=Mobile}" />
                                        <DataGridTextColumn Header="Country" Width="60" Binding="{Binding Path=Country}" />
                                        <DataGridTextColumn Header="License" Width="100" Binding="{Binding Path=Licenses}" />
                                        <DataGridTextColumn Header="Group" Width="100" Binding="{Binding Path=Groups[0]}" />



                                        <!-- <DataGridComboBoxColumn Header="License" ItemsSource="{Binding Path=Licenses}" DisplayMemberPath="Name"  /> -->
                                    </DataGrid.Columns>
                                </DataGrid>
                                <StackPanel Orientation="Horizontal" Grid.Row="1" Grid.ColumnSpan="2" HorizontalAlignment="Right">
                                    <Button Name="btn_DeleteUsers" Margin="0,0,0,0" VerticalAlignment="Top" HorizontalAlignment="Right" Height="20" Width="50" Background="#FF8B97A2" Foreground="White">Delete</Button>
                                    <Button Name="btn_ClearUsers" Margin="0,0,0,0" VerticalAlignment="Top" HorizontalAlignment="Right" Height="20" Width="50" Background="#FF8B97A2" Foreground="White">Clear</Button>
                                </StackPanel>

                            </Grid>
                        </StackPanel>
                    </GroupBox>
                    <GroupBox Header="Execute">
                        <StackPanel Orientation="Horizontal" HorizontalAlignment="Stretch">
                            <TextBlock VerticalAlignment="Center" Margin="0,0,10,0">Initial User Password:</TextBlock>
                            <PasswordBox VerticalAlignment="Center" Width="150" Margin="0,0,0,0" Name="Txt_OfficePassword"></PasswordBox>
                            <TextBox VerticalAlignment="Center" Width="150" Margin="0,0,0,0" Name="Txt_OfficePasswordVisible" IsReadOnly="True"  Visibility="Collapsed"></TextBox>
                            <Button Name="Btn_ShowOfficePassword" VerticalAlignment="Center" Margin="0">Show</Button>
                            <TextBlock VerticalAlignment="Center" Margin="20,0,0,0">Mail Suffix:</TextBlock>
                            <TextBox IsReadOnly="True" Name="Txt_Mail"  Width="200" VerticalAlignment="Center" />
                            <Button Name="Btn_OfficeDeploy" HorizontalAlignment="Right" Foreground="White" FontWeight="Bold" Background="#FF24BE43">Provision Office 365</Button>
                        </StackPanel>
                    </GroupBox>
                </StackPanel>
            </TabItem>
            <TabItem Name="Tab_Azure" Header="Azure">
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="71*"/>
                        <ColumnDefinition Width="1016*"/>
                    </Grid.ColumnDefinitions>
                    <Grid.RowDefinitions>
                        <RowDefinition Name="RoleTitle" />
                        <RowDefinition Name="RoleContent" />

                    </Grid.RowDefinitions>
                    <StackPanel Grid.ColumnSpan="2" Grid.RowSpan="2">
                        <GroupBox Name="grpzureConnection" Header="1. Azure Connection" >
                            <StackPanel Orientation="Horizontal">

                                <Label VerticalAlignment="Top" HorizontalAlignment="Left">Subscription:</Label>
                                <ComboBox Name="Cmb_Subscriptions" VerticalAlignment="Center" HorizontalAlignment="Left"  Width="250"></ComboBox>
                            </StackPanel>
                        </GroupBox>
                        <GroupBox Header="2. Scenario Selection" >
                            <Grid>
                                <StackPanel VerticalAlignment="Center" HorizontalAlignment="Stretch">

                                    <RadioButton Name="Rad_Small" Tag="small" FontSize="20" IsChecked="True" VerticalAlignment="Center" VerticalContentAlignment="Center">Small</RadioButton>
                                    <RadioButton Name="Rad_Medium" Tag="medium"  FontSize="20" VerticalAlignment="Center" VerticalContentAlignment="Center">Medium</RadioButton>
                                    <RadioButton Name="Rad_Large" Tag="large" FontSize="20" VerticalAlignment="Center" VerticalContentAlignment="Center" >Large</RadioButton>
                                </StackPanel>
                                <!--<Button Name="btn_Small" Margin="0,20,0,0" VerticalAlignment="Top" HorizontalAlignment="Left" Height="30" Width="100" Background="#FF0088FF" Foreground="White">Small</Button>
                            <Button Name="btn_Medium" Margin="0,60,0,0" VerticalAlignment="Top" HorizontalAlignment="Left" Height="30" Width="100" Background="#FF277CC9" Foreground="White">Medium</Button>
                            <Button Name="btn_Large" Margin="0,100,0,0" VerticalAlignment="Top" HorizontalAlignment="Left" Height="30" Width="100" Background="#FF3E59C5" Foreground="White">Large</Button>

                            <CheckBox Name="Chk_AzureSmall" Margin="150,30,0,0" Content="Deploy VNet, subnet, Server and enable AD, file and RDS services"></CheckBox>
                            <CheckBox Name="Chk_AzureMedium" Margin="150,70,0,0" Content="Deploy VNet, subnets, Server and enable AD, file and RDS services"></CheckBox>
                            <CheckBox Name="Chk_AzureLarge" Margin="150,110,0,0" Content="Deploy VNet, subnets, Server and enable AD, file and RDS (dedicated) services"></CheckBox> -->
                            </Grid>
                        </GroupBox>
                        <GroupBox Header="3. Additional Options">

                            <Grid HorizontalAlignment="Left">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="200" />
                                    <ColumnDefinition Width="200"/>

                                </Grid.ColumnDefinitions>
                                <Grid.RowDefinitions>
                                    <RowDefinition />
                                    <RowDefinition />
                                    <RowDefinition />
                                    <RowDefinition />
                                    <RowDefinition />
                                    <RowDefinition />
                                    <RowDefinition />
                                </Grid.RowDefinitions>

                                <Label Grid.Column="0" Grid.Row="0" Grid.ColumnSpan="2">Storage Type:</Label>
                                <ComboBox Grid.Column="2" Grid.Row="0" Name="Cmb_StorageType" Width="200">
                                    <ComboBoxItem IsSelected="True" Tag="Standard_LRS">Locally Redundant (standard)</ComboBoxItem>
                                    <ComboBoxItem Tag="Standard_ZRS">Zone-Redundant (standard)</ComboBoxItem>
                                    <ComboBoxItem Tag="Standard_GRS">Geo-Redundant (standard)</ComboBoxItem>
                                    <ComboBoxItem Tag="Standard_RAGRS">Read-Access Geo-Redundant (standard)</ComboBoxItem>
                                    <ComboBoxItem Tag="Premium_LRS">Locally Redundant (premium)</ComboBoxItem>

                                </ComboBox>

                                <Label Grid.Column="0" Grid.Row="1" Grid.ColumnSpan="2">OS:</Label>
                                <ComboBox Grid.Column="2" Grid.Row="1" Name="Cmb_OS">
                                    <ComboBoxItem Tag="2016" IsSelected="True">2016</ComboBoxItem>
                                    <ComboBoxItem Tag="2012R2">2012R2</ComboBoxItem>
                                </ComboBox>


                                <Label Grid.Column="0" Grid.Row="2" Grid.ColumnSpan="2">Provision additional VM:</Label>
                                <ComboBox Grid.Column="2" Grid.Row="2" Name="Cmb_ExtraVMSize">
                                    <ComboBoxItem Tag="none" IsSelected="True">No</ComboBoxItem>
                                    <ComboBoxItem Tag="small">Small</ComboBoxItem>
                                    <ComboBoxItem Tag="medium">Medium</ComboBoxItem>
                                </ComboBox>


                                <Label Grid.Column="0" Grid.Row="3" Grid.ColumnSpan="3">Provision SQL SaaS:</Label>
                                <ComboBox Grid.Column="2" Grid.Row="3" Name="Cmb_ExtraSQLSize">
                                    <ComboBoxItem Tag="none" IsSelected="True">No</ComboBoxItem>
                                    <ComboBoxItem Tag="small">Yes</ComboBoxItem>

                                </ComboBox>

                                <Label Grid.Column="0" Grid.Row="4" Grid.ColumnSpan="2">Provision Azure Backup Service:</Label>
                                <ComboBox Grid.Column="2" Grid.Row="4" Name="Cmb_Backup">
                                    <ComboBoxItem Tag="none" IsSelected="True">No</ComboBoxItem>
                                    <ComboBoxItem Tag="standard">Yes</ComboBoxItem>

                                </ComboBox>
                                <Label Grid.Column="0" Grid.Row="5" Grid.ColumnSpan="2">Provision VPN:</Label>
                                <ComboBox Grid.Column="2" Grid.Row="5" Name="Cmb_VPN">
                                    <ComboBoxItem Tag="none" IsSelected="True">No</ComboBoxItem>
                                    <ComboBoxItem Tag="basic">Yes</ComboBoxItem>

                                </ComboBox>

                                <!-- <CheckBox Name="Chk_AzureSQL" Margin="150,10,0,0" Content="Deploy Azure SQL database"></CheckBox>
                            <CheckBox Name="Chk_AzureVM" Margin="150,50,0,0" Content="Deploy Extra VM"></CheckBox> -->
                            </Grid>
                        </GroupBox>
                        <GroupBox Grid.Row="1" Header="4. Location">
                            <StackPanel HorizontalAlignment="Stretch">
                                <Label VerticalAlignment="Center" HorizontalAlignment="Center">Location</Label>
                                <ComboBox Name="Cmb_PrimaryLocation" Width="250" VerticalAlignment="Center" HorizontalAlignment="Center" />
                                <StackPanel Name="Spl_ServiceUnavailable">
                                    <Label VerticalAlignment="Center" HorizontalAlignment="Stretch" Margin="10,10,10,10" MinWidth="0" MaxWidth="300" >
                                        <Label.Resources>
                                            <Style TargetType="TextBlock">
                                                <Setter Property="TextWrapping" Value="Wrap" />
                                            </Style>

                                        </Label.Resources>
                                        <Label.Background>
                                            <SolidColorBrush Color="#FF0088FF" />
                                        </Label.Background>
                                        <Label.Foreground>
                                            <SolidColorBrush Color="White" />
                                        </Label.Foreground>
                                        <TextBlock>WARNING: The monitoring, automation and recovery services are not available in this region.<LineBreak />
                                    Please select a fallback action:</TextBlock>
                                    </Label>
                                    <ComboBox Name="Cmb_FallbackAction" Width="300" VerticalAlignment="Center" HorizontalAlignment="Center">
                                        <!-- <ComboBoxItem Tag="none" IsSelected="True">Continue deployment without these services</ComboBoxItem> -->
                                        <ComboBoxItem Tag="westeurope" IsSelected="True">Deploy impacted services to West-Europe</ComboBoxItem>
                                        <ComboBoxItem Tag="southeastasia">Deploy impacted services to SouthEast-Asia</ComboBoxItem>
                                        <ComboBoxItem Tag="australiasoutheast">Deploy impacted services to Australia-SouthEast</ComboBoxItem>

                                    </ComboBox>
                                </StackPanel>

                            </StackPanel>
                        </GroupBox>
                        <GroupBox Grid.Row="1" Header="5. Execute" >
                            <StackPanel Orientation="Horizontal" VerticalAlignment="Center" HorizontalAlignment="Center">
                                <Label VerticalAlignment="Center">Admin Password:</Label>
                                <PasswordBox VerticalAlignment="Center" Width="150" Name="Txt_AzurePassword" />
                                <TextBox VerticalAlignment="Center" Width="150" Name="Txt_AzurePasswordVisible"  Visibility="Collapsed" IsReadOnly="True"></TextBox>
                                <Button Name="Btn_ShowAzurePassword" Margin="0" VerticalAlignment="Center">Show</Button>
                                <Label VerticalAlignment="Center" Margin="20,0,0,0">Customer Name:</Label>
                                <TextBox VerticalAlignment="Center" Name="Txt_Customer" Width="100" />
                                <Button Name="btn_Deploy" Foreground="White" VerticalAlignment="Center" HorizontalAlignment="Center" FontWeight="Bold"   Background="#FF24BE43">Provision Azure</Button>
                            </StackPanel>
                        </GroupBox>

                    </StackPanel>







                </Grid>
            </TabItem>
            <TabItem Name="Tab_Log" Header="Log" VerticalAlignment="Stretch" HorizontalAlignment="Stretch">

                <Grid VerticalAlignment="Stretch" HorizontalAlignment="Stretch">
                    <StackPanel>
                        <GroupBox Grid.ColumnSpan="3" Header="Deployment" VerticalAlignment="Stretch" HorizontalAlignment="Stretch">
                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="150" />
                                    <ColumnDefinition Width="500" />
                                </Grid.ColumnDefinitions>
                                <Grid.RowDefinitions>
                                    <RowDefinition />
                                    <RowDefinition />
                                    <RowDefinition />
                                    <RowDefinition />
                                    <RowDefinition />
                                </Grid.RowDefinitions>
                                <Label Grid.Column="0" Grid.Row="0">Deployment Type</Label>
                                <TextBox Grid.Column="1" Grid.Row="0" IsReadOnly="True" VerticalAlignment="Center" HorizontalAlignment="Center" Name="Txt_DeploymentType" Width="500"></TextBox>
                                <Label Grid.Column="0" Grid.Row="1">Deployment Duration</Label>
                                <TextBox Grid.Column="1" Grid.Row="1" VerticalAlignment="Center" IsReadOnly="True" HorizontalAlignment="Center" Name="Txt_DeploymentTime" Width="500"></TextBox>
                                <Label Grid.Column="0" Grid.Row="3" VerticalAlignment="Top">Deployment Status</Label>
                                <TextBox Grid.Column="1" Grid.Row="3" TextAlignment="Center" VerticalAlignment="Center" IsReadOnly="True" HorizontalAlignment="Center" Name="Txt_DeploymentStatus" Width="500" Height="100"></TextBox>
                                <StackPanel Grid.ColumnSpan="2" Orientation="Horizontal" Grid.Column="0" Grid.Row="4">
                                    <Button Name="Btn_CopyCredential">Copy Credentials</Button>
                                    <Button Name="Btn_CopyCommand">Copy PowerShell Command</Button>
                                </StackPanel>
                            </Grid>


                        </GroupBox>
                        <GroupBox Grid.ColumnSpan="3" Header="Log" VerticalAlignment="Stretch" HorizontalAlignment="Stretch">
                            <StackPanel>

                                <DataGrid Name="Dgr_Log" AutoGenerateColumns="False" HorizontalAlignment="Stretch" VerticalAlignment="Stretch" Height="300" IsReadOnly="True">
                                    <DataGrid.Columns>
                                        <DataGridTextColumn Header="Severity" Binding="{Binding Path=Severity}" />
                                        <DataGridTextColumn Header="Component" Binding="{Binding Path=Component}" />
                                        <DataGridTextColumn Header="Message" Binding="{Binding Path=Message}" />
                                        <DataGridTextColumn Header="Timestamp" Binding="{Binding Path=Timestamp}" />
                                    </DataGrid.Columns>
                                </DataGrid>
                                <Grid HorizontalAlignment="Stretch">
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition />
                                        <ColumnDefinition />
                                    </Grid.ColumnDefinitions>
                                    <CheckBox Grid.Column="0" Margin="0,0,5,0" Name="Chk_AutoScroll" IsChecked="True">Auto-Scroll</CheckBox>
                                    <StackPanel Grid.Column="1" Orientation="Horizontal" HorizontalAlignment="Right">
                                        <TextBlock Visibility="Collapsed" VerticalAlignment="Center" HorizontalAlignment="Right" Margin="0,0,5,0" Name="Txb_LogName">LogName</TextBlock>
                                        <Button Background="Transparent" Margin="0,0,0,0" BorderBrush="Transparent" VerticalAlignment="Center" Name="Btn_OpenLog">Open Log Location</Button>
                                    </StackPanel>

                                </Grid>

                            </StackPanel>
                        </GroupBox>

                    </StackPanel>

                </Grid>
            </TabItem>
        </TabControl>


    </Grid>

</Window>
"@
    }
    return $xaml.GUI.Replace("D:\OneDrive - Inovativ\Projects\Microsoft\SBS\dev\GUI\src\","$global:root\gui\")
}