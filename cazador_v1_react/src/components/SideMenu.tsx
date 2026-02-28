import React from 'react';
import { View, Text, Pressable, StyleSheet, Modal } from 'react-native';
import { X, ShieldCheck, Users, Briefcase, Key, User, Bell, LogOut } from 'lucide-react-native';
import { colors, spacing, borderRadius } from '../theme';
import type { AppState } from '../types';

interface SideMenuProps {
  visible: boolean;
  currentState: AppState;
  onClose: () => void;
  onNavigate: (state: AppState) => void;
  onLogout: () => void;
}

const menuItems: { state: AppState; label: string; Icon: typeof Users }[] = [
  { state: 'clients', label: 'Lista de Clientes', Icon: Users },
  { state: 'projects', label: 'Proyectos', Icon: Briefcase },
  { state: 'reservations', label: 'Reservas', Icon: Key },
  { state: 'subordinates', label: 'Dateros', Icon: User },
];

export function SideMenu({
  visible,
  currentState,
  onClose,
  onNavigate,
  onLogout,
}: SideMenuProps) {
  return (
    <Modal visible={visible} transparent animationType="slide" onRequestClose={onClose}>
      <Pressable style={styles.backdrop} onPress={onClose} />
      <View style={styles.drawer}>
        <View style={styles.header}>
          <View style={styles.logoRow}>
            <View style={styles.logoIcon}>
              <ShieldCheck size={18} color={colors.white} />
            </View>
            <Text style={styles.logoText}>Veridian</Text>
          </View>
          <Pressable onPress={onClose} style={styles.closeBtn}>
            <X size={20} color={colors.zinc[400]} />
          </Pressable>
        </View>
        <View style={styles.menu}>
          {menuItems.map(({ state, label, Icon }) => {
            const isActive = currentState === state;
            return (
              <Pressable
                key={state}
                onPress={() => onNavigate(state)}
                style={[styles.menuItem, isActive && styles.menuItemActive]}
              >
                <Icon size={20} color={isActive ? colors.emerald[600] : colors.zinc[500]} />
                <Text style={[styles.menuItemText, isActive && styles.menuItemTextActive]}>
                  {label}
                </Text>
              </Pressable>
            );
          })}
          <View style={styles.divider} />
          <Pressable style={styles.menuItem}>
            <Bell size={20} color={colors.zinc[500]} />
            <Text style={styles.menuItemText}>Notificaciones</Text>
          </Pressable>
        </View>
        <View style={styles.footer}>
          <Pressable onPress={onLogout} style={({ pressed }) => [styles.logoutBtn, pressed && styles.logoutBtnPressed]}>
            <LogOut size={20} color={colors.red[500]} />
            <Text style={styles.logoutText}>Cerrar Sesión</Text>
          </Pressable>
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  backdrop: { flex: 1, backgroundColor: 'rgba(0,0,0,0.2)' },
  drawer: {
    position: 'absolute',
    left: 0,
    top: 0,
    bottom: 0,
    width: 280,
    backgroundColor: colors.white,
    padding: spacing.xxl,
    shadowColor: colors.black,
    shadowOffset: { width: 2, height: 0 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 8,
  },
  header: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 40 },
  logoRow: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm },
  logoIcon: {
    width: 32,
    height: 32,
    borderRadius: borderRadius.sm,
    backgroundColor: colors.zinc[900],
    alignItems: 'center',
    justifyContent: 'center',
  },
  logoText: { fontWeight: '700', fontSize: 18, color: colors.zinc[900] },
  closeBtn: { padding: spacing.sm },
  menu: { flex: 1, gap: spacing.sm },
  menuItem: { flexDirection: 'row', alignItems: 'center', gap: spacing.lg, padding: spacing.lg, borderRadius: borderRadius.xl },
  menuItemActive: { backgroundColor: colors.emerald[50] },
  menuItemText: { fontSize: 16, color: colors.zinc[500] },
  menuItemTextActive: { color: colors.emerald[600], fontWeight: '700' },
  divider: { height: 1, backgroundColor: colors.zinc[100], marginVertical: spacing.lg },
  footer: { paddingTop: spacing.xxl, borderTopWidth: 1, borderTopColor: colors.zinc[100] },
  logoutBtn: { flexDirection: 'row', alignItems: 'center', gap: spacing.lg, padding: spacing.lg, borderRadius: borderRadius.xl },
  logoutBtnPressed: { backgroundColor: colors.red[50] },
  logoutText: { fontSize: 16, fontWeight: '700', color: colors.red[500] },
});
