
{:ok, _} = LiveViewNativeTest.Endpoint.start_link()

# For mix tests
Mix.shell(Mix.Shell.Process)

ExUnit.start()
