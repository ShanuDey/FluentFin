using FluentFin.Core.ViewModels;
using FluentFin.ViewModels;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Input;
using Microsoft.UI.Xaml;

namespace FluentFin.Views;

public sealed partial class TitleBarControl : UserControl
{
	public TitleBarViewModel ViewModel { get; } = (TitleBarViewModel)App.GetService<ITitleBarViewModel>();

	public TitleBarControl()
	{
		InitializeComponent();
	}

	private void TitleBar_BackRequested(Microsoft.UI.Xaml.Controls.TitleBar sender, object args)
	{
		ViewModel.GoBack();
	}

	private void CloseTitleBarFooterFlyout(object sender, Microsoft.UI.Xaml.RoutedEventArgs e)
	{
		FooterFlyout.Hide();
	}

	private void KeyboardAccelerator_Invoked(KeyboardAccelerator sender, KeyboardAcceleratorInvokedEventArgs args)
	{
		if (FocusManager.GetFocusedElement() is AutoSuggestBox sb && sb == SearchBox)
		{
			return;
		}

		SearchBox.Focus(Microsoft.UI.Xaml.FocusState.Programmatic);
	}

	private void ToggleSidebarButton_Click(object sender, RoutedEventArgs e)
	{
		var shellViewModel = App.GetService<ShellViewModel>();
		shellViewModel.ToggleSidebarCommand.Execute(null);
	}
}
