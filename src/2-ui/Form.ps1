[String]$XAML_FORM = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="$($HOST.UI.RawUI.WindowTitle)"
    MinWidth="$FORM_MIN_WIDTH" MinHeight="$FORM_MIN_HEIGHT"
    Width="$FORM_MIN_WIDTH" Height="$FORM_MIN_HEIGHT"
    WindowStartupLocation="CenterScreen"
    WindowStyle="None" AllowsTransparency="True" Background="Transparent"
    ResizeMode="NoResize">

    <Window.Resources>

        <!-- Primary Button -->
        <Style x:Key="Win11Button" TargetType="Button">
            <Setter Property="Background" Value="{DynamicResource AccentColor}" />
            <Setter Property="Foreground" Value="White" />
            <Setter Property="BorderThickness" Value="1" />
            <Setter Property="BorderBrush" Value="{DynamicResource AccentColor}" />
            <Setter Property="FontFamily" Value="Segoe UI" />
            <Setter Property="FontSize" Value="$FONT_SIZE_BUTTON" />
            <Setter Property="Padding" Value="16,4" />
            <Setter Property="Margin" Value="0,4,0,4" />
            <Setter Property="Height" Value="32" />
            <Setter Property="Cursor" Value="Hand" />
            <Setter Property="HorizontalAlignment" Value="Stretch" />
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border"
                                Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="4"
                                Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" />
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="{DynamicResource AccentHoverColor}" />
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="{DynamicResource AccentPressedColor}" />
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="border" Property="Background" Value="{DynamicResource ButtonDisabledColor}" />
                                <Setter Property="Foreground" Value="{DynamicResource ButtonTextDisabledColor}" />
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Title Bar Button -->
        <Style x:Key="TitleBarButton" TargetType="Button">
            <Setter Property="Background" Value="Transparent" />
            <Setter Property="Foreground" Value="{DynamicResource FgColor}" />
            <Setter Property="BorderThickness" Value="0" />
            <Setter Property="Width" Value="46" />
            <Setter Property="Height" Value="32" />
            <Setter Property="FontFamily" Value="Segoe MDL2 Assets" />
            <Setter Property="FontSize" Value="10" />
            <Setter Property="Cursor" Value="Hand" />
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" BorderThickness="0">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" />
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="{DynamicResource BorderColor}" />
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Close Button -->
        <Style x:Key="CloseButton" TargetType="Button" BasedOn="{StaticResource TitleBarButton}">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" BorderThickness="0" CornerRadius="0,7,0,0">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" />
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="{DynamicResource CloseHoverColor}" />
                                <Setter Property="Foreground" Value="White" />
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- CheckBox -->
        <Style x:Key="Win11CheckBox" TargetType="CheckBox">
            <Setter Property="Foreground" Value="{DynamicResource FgColor}" />
            <Setter Property="FontFamily" Value="Segoe UI" />
            <Setter Property="FontSize" Value="$FONT_SIZE_NORMAL" />
            <Setter Property="Margin" Value="0,3,0,3" />
            <Setter Property="Cursor" Value="Hand" />
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="CheckBox">
                        <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                            <Border x:Name="checkBorder"
                                    Width="18" Height="18"
                                    CornerRadius="4"
                                    BorderThickness="1"
                                    BorderBrush="{DynamicResource CheckBoxBorderColor}"
                                    Background="{DynamicResource CheckBoxBgColor}"
                                    Margin="0,0,8,0">
                                <TextBlock x:Name="checkMark"
                                           Text="&#xE73E;"
                                           FontFamily="Segoe MDL2 Assets"
                                           FontSize="12"
                                           Foreground="White"
                                           HorizontalAlignment="Center"
                                           VerticalAlignment="Center"
                                           Visibility="Collapsed" />
                            </Border>
                            <ContentPresenter VerticalAlignment="Center" />
                        </StackPanel>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsChecked" Value="True">
                                <Setter TargetName="checkBorder" Property="Background" Value="{DynamicResource AccentColor}" />
                                <Setter TargetName="checkBorder" Property="BorderBrush" Value="{DynamicResource AccentColor}" />
                                <Setter TargetName="checkMark" Property="Visibility" Value="Visible" />
                            </Trigger>
                            <MultiTrigger>
                                <MultiTrigger.Conditions>
                                    <Condition Property="IsChecked" Value="True" />
                                    <Condition Property="IsMouseOver" Value="True" />
                                </MultiTrigger.Conditions>
                                <Setter TargetName="checkBorder" Property="Background" Value="{DynamicResource AccentHoverColor}" />
                                <Setter TargetName="checkBorder" Property="BorderBrush" Value="{DynamicResource AccentHoverColor}" />
                            </MultiTrigger>
                            <MultiTrigger>
                                <MultiTrigger.Conditions>
                                    <Condition Property="IsChecked" Value="False" />
                                    <Condition Property="IsMouseOver" Value="True" />
                                </MultiTrigger.Conditions>
                                <Setter TargetName="checkBorder" Property="Background" Value="{DynamicResource CheckBoxHoverColor}" />
                            </MultiTrigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter Property="Opacity" Value="0.5" />
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- TabControl -->
        <Style TargetType="TabControl">
            <Setter Property="Background" Value="Transparent" />
            <Setter Property="BorderThickness" Value="0" />
            <Setter Property="Padding" Value="0" />
        </Style>

        <!-- TabItem -->
        <Style TargetType="TabItem">
            <Setter Property="Foreground" Value="{DynamicResource FgColor}" />
            <Setter Property="FontFamily" Value="Segoe UI" />
            <Setter Property="FontSize" Value="$FONT_SIZE_NORMAL" />
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TabItem">
                        <Border x:Name="tabBorder"
                                Background="Transparent"
                                CornerRadius="4,4,0,0"
                                Padding="12,6,12,6"
                                Margin="2,0,2,0"
                                Cursor="Hand">
                            <ContentPresenter ContentSource="Header" HorizontalAlignment="Center" VerticalAlignment="Center" />
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="tabBorder" Property="Background" Value="{DynamicResource CardBgColor}" />
                                <Setter Property="Foreground" Value="{DynamicResource AccentColor}" />
                            </Trigger>
                            <MultiTrigger>
                                <MultiTrigger.Conditions>
                                    <Condition Property="IsSelected" Value="False" />
                                    <Condition Property="IsMouseOver" Value="True" />
                                </MultiTrigger.Conditions>
                                <Setter TargetName="tabBorder" Property="Background" Value="{DynamicResource TabHoverColor}" />
                            </MultiTrigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- ScrollBar Thumb -->
        <Style TargetType="ScrollBar">
            <Setter Property="Width" Value="8" />
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ScrollBar">
                        <Track x:Name="PART_Track" IsDirectionReversed="True">
                            <Track.Thumb>
                                <Thumb>
                                    <Thumb.Style>
                                        <Style TargetType="Thumb">
                                            <Setter Property="Template">
                                                <Setter.Value>
                                                    <ControlTemplate TargetType="Thumb">
                                                        <Border x:Name="thumbBorder"
                                                                CornerRadius="4"
                                                                Background="{DynamicResource ScrollBarThumbColor}"
                                                                Margin="1,0,1,0" />
                                                        <ControlTemplate.Triggers>
                                                            <Trigger Property="IsMouseOver" Value="True">
                                                                <Setter TargetName="thumbBorder" Property="Background" Value="{DynamicResource ScrollBarThumbHoverColor}" />
                                                            </Trigger>
                                                        </ControlTemplate.Triggers>
                                                    </ControlTemplate>
                                                </Setter.Value>
                                            </Setter>
                                        </Style>
                                    </Thumb.Style>
                                </Thumb>
                            </Track.Thumb>
                        </Track>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- ProgressBar -->
        <Style TargetType="ProgressBar">
            <Setter Property="Foreground" Value="{DynamicResource AccentColor}" />
            <Setter Property="Background" Value="{DynamicResource BorderColor}" />
            <Setter Property="BorderThickness" Value="0" />
            <Setter Property="Height" Value="4" />
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ProgressBar">
                        <Grid>
                            <Border x:Name="PART_Track" Background="{TemplateBinding Background}" CornerRadius="2" />
                            <Border x:Name="PART_Indicator"
                                    Background="{TemplateBinding Foreground}"
                                    CornerRadius="2"
                                    HorizontalAlignment="Left" />
                        </Grid>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

    </Window.Resources>

    <Border x:Name="WindowBorder"
            BorderBrush="{DynamicResource BorderColor}"
            BorderThickness="1"
            CornerRadius="8"
            Background="{DynamicResource BgColor}">

        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="32" />
                <RowDefinition Height="*" />
                <RowDefinition Height="Auto" />
            </Grid.RowDefinitions>

            <!-- Title Bar -->
            <Grid x:Name="TitleBar" Grid.Row="0" Background="Transparent">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*" />
                    <ColumnDefinition Width="Auto" />
                    <ColumnDefinition Width="Auto" />
                </Grid.ColumnDefinitions>

                <TextBlock Grid.Column="0"
                           Text="$($HOST.UI.RawUI.WindowTitle)"
                           Foreground="{DynamicResource FgColor}"
                           FontFamily="Segoe UI"
                           FontSize="12"
                           VerticalAlignment="Center"
                           Margin="12,0,0,0" />

                <Button x:Name="MinimizeButton" Grid.Column="1"
                        Content="&#xE949;"
                        Style="{StaticResource TitleBarButton}" />

                <Button x:Name="CloseButton" Grid.Column="2"
                        Content="&#xE8BB;"
                        Style="{StaticResource CloseButton}" />
            </Grid>

            <!-- Tab Content -->
            <TabControl x:Name="TabControl" Grid.Row="1" Margin="8,0,8,0" />

            <!-- Bottom: Progress + Log -->
            <Grid Grid.Row="2" Margin="8,4,8,8">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto" />
                    <RowDefinition Height="180" />
                </Grid.RowDefinitions>

                <ProgressBar x:Name="ProgressBar" Grid.Row="0" Margin="0,0,0,4" />

                <Border Grid.Row="1"
                        Background="{DynamicResource LogBgColor}"
                        CornerRadius="4"
                        BorderBrush="{DynamicResource BorderColor}"
                        BorderThickness="1"
                        Padding="4">
                    <RichTextBox x:Name="LogTextBox"
                                 IsReadOnly="True"
                                 IsReadOnlyCaretVisible="False"
                                 Background="Transparent"
                                 BorderThickness="0"
                                 Foreground="{DynamicResource LogFgColor}"
                                 FontFamily="Consolas"
                                 FontSize="11"
                                 Padding="0"
                                 VerticalScrollBarVisibility="Auto">
                        <FlowDocument PagePadding="0">
                            <Paragraph Margin="0" />
                        </FlowDocument>
                    </RichTextBox>
                </Border>
            </Grid>
        </Grid>
    </Border>
</Window>
"@

Set-Variable -Option Constant FORM ([Windows.Window]([Windows.Markup.XamlReader]::Parse($XAML_FORM)))

Set-ThemeResources $FORM

Set-Variable -Option Constant TAB_CONTROL ([Windows.Controls.TabControl]$FORM.FindName('TabControl'))
Set-Variable -Option Constant PROGRESSBAR ([Windows.Controls.ProgressBar]$FORM.FindName('ProgressBar'))
Set-Variable -Option Constant LOG_BOX ([Windows.Controls.RichTextBox]$FORM.FindName('LogTextBox'))
Set-Variable -Option Constant LOG ([Windows.Documents.Paragraph]$LOG_BOX.Document.Blocks.FirstBlock)
Set-Variable -Option Constant TitleBar ([Windows.Controls.Grid]$FORM.FindName('TitleBar'))

$FORM.Icon = [Windows.Interop.Imaging]::CreateBitmapSourceFromHIcon(
    $ICON_DEFAULT.Handle,
    [Windows.Int32Rect]::Empty,
    [Windows.Media.Imaging.BitmapSizeOptions]::FromEmptyOptions()
)

$FORM.FindName('MinimizeButton').Add_Click( { $FORM.WindowState = 'Minimized' } )
$FORM.FindName('CloseButton').Add_Click( { $FORM.Close() } )

$TitleBar.Add_MouseLeftButtonDown( {
        try { $FORM.DragMove() } catch {}
    } )

$FORM.Add_ContentRendered( { Initialize-App } )
$FORM.Add_Closing( { Reset-State } )
