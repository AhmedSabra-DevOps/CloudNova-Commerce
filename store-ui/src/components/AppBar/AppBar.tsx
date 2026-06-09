import * as React from 'react';
import { styled, alpha, useTheme } from '@mui/material/styles';
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Toolbar from '@mui/material/Toolbar';
import IconButton from '@mui/material/IconButton';
import Typography from '@mui/material/Typography';
import InputBase from '@mui/material/InputBase';
import Badge from '@mui/material/Badge';
import MenuItem from '@mui/material/MenuItem';
import Menu from '@mui/material/Menu';
import Drawer from '@mui/material/Drawer';
import List from '@mui/material/List';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemText from '@mui/material/ListItemText';
import Divider from '@mui/material/Divider';
import MenuIcon from '@mui/icons-material/Menu';
import SearchIcon from '@mui/icons-material/Search';
import AccountCircle from '@mui/icons-material/AccountCircle';
import ShoppingCartIcon from '@mui/icons-material/ShoppingCart';
import MoreIcon from '@mui/icons-material/MoreVert';
import ThemeContext from "../layout/ThemeContext";
import Brightness4Icon from '@mui/icons-material/Brightness4';
import Brightness7Icon from '@mui/icons-material/Brightness7';
import { useNavigate } from "react-router-dom";
import Link from '@mui/material/Link';
import { getCart } from '../../api/cart';

const Search = styled('div')(({ theme }) => ({
  position: 'relative',
  borderRadius: theme.shape.borderRadius,
  backgroundColor: alpha(theme.palette.common.white, 0.15),
  '&:hover': {
    backgroundColor: alpha(theme.palette.common.white, 0.25),
  },
  marginRight: theme.spacing(2),
  marginLeft: 0,
  width: '100%',
  [theme.breakpoints.up('sm')]: {
    marginLeft: theme.spacing(3),
    width: 'auto',
  },
}));

const SearchIconWrapper = styled('div')(({ theme }) => ({
  padding: theme.spacing(0, 2),
  height: '100%',
  position: 'absolute',
  pointerEvents: 'none',
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
}));

const StyledInputBase = styled(InputBase)(({ theme }) => ({
  color: 'inherit',
  width: '100%',
  '& .MuiInputBase-input': {
    padding: theme.spacing(1, 1, 1, 0),
    paddingLeft: `calc(1em + ${theme.spacing(4)})`,
    transition: theme.transitions.create('width'),
    width: '100%',
  },
}));

export default function PrimarySearchAppBar() {
  const navigate = useNavigate();
  const theme = useTheme();
  const colorMode = React.useContext(ThemeContext);

  const [searchQuery, setSearchQuery] = React.useState('');
  const [cartCount, setCartCount] = React.useState(0);

  const [drawerOpen, setDrawerOpen] = React.useState(false);
  const [anchorEl, setAnchorEl] = React.useState<null | HTMLElement>(null);
  const [mobileMoreAnchorEl, setMobileMoreAnchorEl] = React.useState<null | HTMLElement>(null);

  const isMenuOpen = Boolean(anchorEl);
  const isMobileMenuOpen = Boolean(mobileMoreAnchorEl);

  const openDrawer = () => {
    setDrawerOpen(true);
  };

  const closeDrawer = () => {
    setDrawerOpen(false);
  };

  const goToPage = (path: string) => {
    navigate(path);
    closeDrawer();
    handleMenuClose();
  };

  const handleProfileMenuOpen = (event: React.MouseEvent<HTMLElement>) => {
    setAnchorEl(event.currentTarget);
  };

  const handleMobileMenuOpen = (event: React.MouseEvent<HTMLElement>) => {
    setMobileMoreAnchorEl(event.currentTarget);
  };

  const handleMobileMenuClose = () => {
    setMobileMoreAnchorEl(null);
  };

  const handleMenuClose = () => {
    setAnchorEl(null);
    handleMobileMenuClose();
  };

  const handleSearch = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' && searchQuery.trim()) {
      navigate('/search?q=' + encodeURIComponent(searchQuery.trim()));
    }
  };

  React.useEffect(() => {
    const loadCartCount = async () => {
      try {
        const cart = await getCart();

        if (Array.isArray(cart)) {
          const firstCart = cart[0];
          const total = firstCart?.items?.reduce(
            (sum: number, item: any) => sum + Number(item.quantity || 0),
            0
          ) || 0;
          setCartCount(total);
          return;
        }

        const total = cart?.items?.reduce(
          (sum: number, item: any) => sum + Number(item.quantity || 0),
          0
        ) || 0;

        setCartCount(total);
      } catch (err) {
        setCartCount(0);
      }
    };

    loadCartCount();
    const interval = setInterval(loadCartCount, 3000);

    return () => clearInterval(interval);
  }, []);

  const menuId = 'primary-search-account-menu';
  const mobileMenuId = 'primary-search-account-menu-mobile';

  const renderMenu = (
    <Menu
      anchorEl={anchorEl}
      anchorOrigin={{ vertical: 'top', horizontal: 'right' }}
      id={menuId}
      keepMounted
      transformOrigin={{ vertical: 'top', horizontal: 'right' }}
      open={isMenuOpen}
      onClose={handleMenuClose}
    >
      <MenuItem onClick={() => goToPage('/profile')}>Profile</MenuItem>
      <MenuItem onClick={() => goToPage('/account')}>My account</MenuItem>
    </Menu>
  );

  const renderMobileMenu = (
    <Menu
      anchorEl={mobileMoreAnchorEl}
      anchorOrigin={{ vertical: 'top', horizontal: 'right' }}
      id={mobileMenuId}
      keepMounted
      transformOrigin={{ vertical: 'top', horizontal: 'right' }}
      open={isMobileMenuOpen}
      onClose={handleMobileMenuClose}
    >
      <MenuItem onClick={() => goToPage('/cart')}>
        <IconButton size="large" color="inherit">
          <Badge badgeContent={cartCount} color="error">
            <ShoppingCartIcon />
          </Badge>
        </IconButton>
        <Typography>Cart</Typography>
      </MenuItem>

      <MenuItem onClick={() => goToPage('/profile')}>
        <IconButton size="large" color="inherit">
          <AccountCircle />
        </IconButton>
        <Typography>Profile</Typography>
      </MenuItem>

      <MenuItem onClick={() => goToPage('/account')}>
        <IconButton size="large" color="inherit">
          <AccountCircle />
        </IconButton>
        <Typography>My account</Typography>
      </MenuItem>
    </Menu>
  );

  const renderDrawer = (
    <Drawer anchor="left" open={drawerOpen} onClose={closeDrawer}>
      <Box sx={{ width: 270 }} role="presentation">
        <Box sx={{ p: 2 }}>
          <Typography variant="h6" fontWeight="bold">
            CloudNova Commerce
          </Typography>
        </Box>

        <Divider />

        <List>
          <ListItemButton onClick={() => goToPage('/')}>
            <ListItemText primary="Home" />
          </ListItemButton>

          <ListItemButton onClick={() => goToPage('/')}>
            <ListItemText primary="Products" />
          </ListItemButton>

          <ListItemButton onClick={() => goToPage('/cart')}>
            <ListItemText primary="Cart" />
          </ListItemButton>

          <ListItemButton onClick={() => goToPage('/profile')}>
            <ListItemText primary="Profile" />
          </ListItemButton>

          <ListItemButton onClick={() => goToPage('/account')}>
            <ListItemText primary="My Account" />
          </ListItemButton>
        </List>

        <Divider />

        <List>
          <ListItemButton onClick={() => goToPage('/contact')}>
            <ListItemText primary="Contact Us" />
          </ListItemButton>

          <ListItemButton onClick={() => goToPage('/about')}>
            <ListItemText primary="About Us" />
          </ListItemButton>

          <ListItemButton onClick={() => goToPage('/terms')}>
            <ListItemText primary="Terms Of Use" />
          </ListItemButton>

          <ListItemButton onClick={() => goToPage('/privacy')}>
            <ListItemText primary="Privacy Policy" />
          </ListItemButton>
        </List>
      </Box>
    </Drawer>
  );

  return (
    <Box sx={{ flexGrow: 1 }}>
      <AppBar position="static">
        <Toolbar>
          <IconButton
            size="large"
            edge="start"
            color="inherit"
            sx={{ mr: 2 }}
            onClick={openDrawer}
            aria-label="open navigation menu"
          >
            <MenuIcon />
          </IconButton>

          <Link
            href="/"
            variant="h5"
            underline="none"
            noWrap
            sx={{
              color: 'white',
              display: 'flex',
              justifyContent: 'flex-end',
              alignItems: 'center'
            }}
          >
            <img src="logo.png" width="32" height="32" alt="logo" />
            CloudNova Commerce
          </Link>

          <Box sx={{ flexGrow: 1 }} />

          <Box sx={{ width: { xs: '45%', md: '40%' } }}>
            <Search>
              <SearchIconWrapper>
                <SearchIcon />
              </SearchIconWrapper>

              <StyledInputBase
                placeholder="Search for products ..."
                inputProps={{ 'aria-label': 'search' }}
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                onKeyDown={handleSearch}
              />
            </Search>
          </Box>

          <Box sx={{ flexGrow: 1 }} />

          <Box sx={{ alignItems: 'center', justifyContent: 'center', display: { xs: 'none', md: 'flex' } }}>
            Switch theme
            <IconButton sx={{ ml: 0 }} onClick={colorMode.toggleColorMode} color="inherit">
              {theme.palette.mode === 'dark' ? <Brightness7Icon /> : <Brightness4Icon />}
            </IconButton>
          </Box>

          <Box sx={{ display: { xs: 'none', md: 'flex' } }}>
            <IconButton
              size="large"
              edge="end"
              aria-controls={menuId}
              aria-haspopup="true"
              onClick={handleProfileMenuOpen}
              color="inherit"
            >
              <AccountCircle />
            </IconButton>

            <IconButton size="large" color="inherit" onClick={() => goToPage('/cart')}>
              <Badge badgeContent={cartCount} color="error">
                <ShoppingCartIcon />
              </Badge>
            </IconButton>
          </Box>

          <Box sx={{ display: { xs: 'flex', md: 'none' } }}>
            <IconButton
              size="large"
              aria-controls={mobileMenuId}
              aria-haspopup="true"
              onClick={handleMobileMenuOpen}
              color="inherit"
            >
              <MoreIcon />
            </IconButton>
          </Box>
        </Toolbar>
      </AppBar>

      {renderMobileMenu}
      {renderMenu}
      {renderDrawer}
    </Box>
  );
}
