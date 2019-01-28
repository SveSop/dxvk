conf = configuration_data()
conf.set('bindir', get_option('bindir'))
configure_file(
  configuration : conf,
  input         : 'setup_dxvk.sh.in',
  output        : 'setup_dxvk.sh',
  install_dir   : get_option('bindir')
)
