import React from 'react';
import { View, Text, TextInput, ScrollView, Pressable, StyleSheet } from 'react-native';
import { Search, Plus, Phone, MoreVertical, Key, Calendar, Edit2, Trash2 } from 'lucide-react-native';
import { colors, spacing, borderRadius } from '../theme';
import type { Client } from '../types';

interface ClientsScreenProps {
  clients: Client[];
  filteredClients: Client[];
  search: string;
  setSearch: (v: string) => void;
  typeFilter: 'all' | 'propio' | 'dateado';
  setTypeFilter: (v: 'all' | 'propio' | 'dateado') => void;
  cityFilter: string;
  setCityFilter: (v: string) => void;
  cities: string[];
  activeMenuId: string | null;
  setActiveMenuId: (v: string | null) => void;
  onAddClient: () => void;
}

export function ClientsScreen({
  filteredClients,
  search,
  setSearch,
  typeFilter,
  setTypeFilter,
  cityFilter,
  setCityFilter,
  cities,
  activeMenuId,
  setActiveMenuId,
  onAddClient,
}: ClientsScreenProps) {
  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <View style={styles.header}>
        <Text style={styles.title}>Clientes</Text>
        <Pressable onPress={onAddClient} style={styles.addBtn}>
          <Plus size={18} color={colors.white} />
        </Pressable>
      </View>
      <View style={styles.searchWrap}>
        <Search size={14} color={colors.zinc[400]} style={styles.searchIcon} />
        <TextInput
          style={styles.searchInput}
          placeholder="Buscar por nombre o teléfono..."
          placeholderTextColor={colors.zinc[400]}
          value={search}
          onChangeText={setSearch}
        />
      </View>
      <View style={styles.filtersRow}>
        <View style={styles.typeFilters}>
          {(['all', 'propio', 'dateado'] as const).map((type) => (
            <Pressable
              key={type}
              onPress={() => setTypeFilter(type)}
              style={[styles.filterChip, typeFilter === type && styles.filterChipActive]}
            >
              <Text style={[styles.filterChipText, typeFilter === type && styles.filterChipTextActive]}>
                {type === 'all' ? 'Todos' : type}
              </Text>
            </Pressable>
          ))}
        </View>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.cityScroll}>
          <Pressable onPress={() => setCityFilter('all')} style={[styles.cityChip, cityFilter === 'all' && styles.cityChipActive]}>
            <Text style={[styles.cityChipText, cityFilter === 'all' && styles.cityChipTextActive]}>Todas</Text>
          </Pressable>
          {cities.map((city) => (
            <Pressable key={city} onPress={() => setCityFilter(city)} style={[styles.cityChip, cityFilter === city && styles.cityChipActive]}>
              <Text style={[styles.cityChipText, cityFilter === city && styles.cityChipTextActive]}>{city}</Text>
            </Pressable>
          ))}
        </ScrollView>
      </View>
      {filteredClients.map((client) => (
        <View key={client.id} style={styles.clientCard}>
          <View style={styles.clientMain}>
            <View style={styles.clientInfo}>
              <View style={styles.clientNameRow}>
                <Text style={styles.clientName}>{client.name}</Text>
                <View style={[styles.badge, client.type === 'propio' ? styles.badgePropio : styles.badgeDateado]}>
                  <Text style={[styles.badgeText, client.type === 'propio' ? styles.badgeTextPropio : styles.badgeTextDateado]}>{client.type}</Text>
                </View>
                <Text style={styles.clientCity}>{client.city}</Text>
              </View>
              <View style={styles.phoneRow}>
                <Phone size={10} color={colors.zinc[400]} />
                <Text style={styles.phoneText}>{client.phone}</Text>
              </View>
            </View>
            <Pressable
              onPress={() => setActiveMenuId(activeMenuId === client.id ? null : client.id)}
              style={styles.moreBtn}
            >
              <MoreVertical size={14} color={activeMenuId === client.id ? colors.zinc[600] : colors.zinc[300]} />
            </Pressable>
          </View>
          {activeMenuId === client.id && (
            <View style={styles.menu}>
              <Pressable style={styles.menuItem}>
                <Key size={14} color={colors.zinc[600]} />
                <Text style={styles.menuItemText}>Reservar (Unidades)</Text>
              </Pressable>
              <Pressable style={styles.menuItem}>
                <Calendar size={14} color={colors.zinc[600]} />
                <Text style={styles.menuItemText}>Agendar</Text>
              </Pressable>
              <Pressable style={styles.menuItem}>
                <Edit2 size={14} color={colors.zinc[600]} />
                <Text style={styles.menuItemText}>Editar</Text>
              </Pressable>
              <Pressable style={styles.menuItem}>
                <Trash2 size={14} color={colors.red[500]} />
                <Text style={[styles.menuItemText, styles.menuItemTextDanger]}>Eliminar</Text>
              </Pressable>
            </View>
          )}
        </View>
      ))}
      {filteredClients.length === 0 && (
        <Text style={styles.empty}>No se encontraron clientes.</Text>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  content: { padding: spacing.lg, gap: spacing.sm },
  header: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  title: { fontSize: 20, fontWeight: '700', color: colors.zinc[900] },
  addBtn: {
    padding: spacing.sm,
    backgroundColor: colors.emerald[500],
    borderRadius: borderRadius.xl,
  },
  searchWrap: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.white,
    borderWidth: 1,
    borderColor: colors.zinc[200],
    borderRadius: borderRadius.xl,
    paddingLeft: spacing.md,
  },
  searchIcon: { marginRight: spacing.sm },
  searchInput: { flex: 1, paddingVertical: spacing.sm, paddingRight: spacing.lg, fontSize: 12 },
  filtersRow: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm },
  typeFilters: { flex: 1, flexDirection: 'row', gap: 4 },
  filterChip: {
    paddingHorizontal: spacing.md,
    paddingVertical: 6,
    borderRadius: borderRadius.sm,
    borderWidth: 1,
    borderColor: colors.zinc[200],
    backgroundColor: colors.white,
  },
  filterChipActive: { backgroundColor: colors.zinc[900], borderColor: colors.zinc[900] },
  filterChipText: { fontSize: 10, fontWeight: '700', color: colors.zinc[500] },
  filterChipTextActive: { color: colors.white },
  cityScroll: { flex: 1, maxHeight: 36 },
  cityChip: { paddingHorizontal: spacing.sm, paddingVertical: 6, borderRadius: borderRadius.sm, marginRight: 4 },
  cityChipActive: { backgroundColor: colors.zinc[200] },
  cityChipText: { fontSize: 10, fontWeight: '700', color: colors.zinc[500] },
  cityChipTextActive: { color: colors.zinc[900] },
  clientCard: {
    backgroundColor: colors.white,
    padding: 10,
    borderRadius: borderRadius.xl,
    borderWidth: 1,
    borderColor: colors.zinc[100],
  },
  clientMain: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  clientInfo: { flex: 1 },
  clientNameRow: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm, flexWrap: 'wrap' },
  clientName: { fontSize: 12, fontWeight: '700', color: colors.zinc[900] },
  badge: { paddingHorizontal: 4, paddingVertical: 2, borderRadius: 4 },
  badgePropio: { backgroundColor: colors.emerald[100] },
  badgeDateado: { backgroundColor: colors.blue[100] },
  badgeText: { fontSize: 7, fontWeight: '700' },
  badgeTextPropio: { color: colors.emerald[700] },
  badgeTextDateado: { color: colors.blue[700] },
  clientCity: { fontSize: 7, fontWeight: '700', color: colors.zinc[400] },
  phoneRow: { flexDirection: 'row', alignItems: 'center', gap: 4, marginTop: 2 },
  phoneText: { fontSize: 9, color: colors.zinc[400] },
  moreBtn: { padding: 6 },
  menu: { marginTop: spacing.sm, paddingTop: spacing.sm, borderTopWidth: 1, borderTopColor: colors.zinc[50], gap: 2 },
  menuItem: { flexDirection: 'row', alignItems: 'center', gap: 10, paddingVertical: 8, paddingHorizontal: spacing.md },
  menuItemText: { fontSize: 10, fontWeight: '700', color: colors.zinc[600] },
  menuItemTextDanger: { color: colors.red[500] },
  empty: { textAlign: 'center', paddingVertical: spacing.xxl, fontSize: 12, color: colors.zinc[400] },
});
